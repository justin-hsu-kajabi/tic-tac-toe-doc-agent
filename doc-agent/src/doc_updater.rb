require 'base64'
require 'octokit'
require 'json'

class DocUpdater
  def initialize
    @anthropic_key = ENV['ANTHROPIC_API_KEY']
    @gemini_key = ENV['GEMINI_API_KEY']
    
    puts "Debug: ANTHROPIC_API_KEY present: #{@anthropic_key ? 'yes' : 'no'}"
    puts "Debug: ANTHROPIC_API_KEY length: #{@anthropic_key&.length || 0}"
    puts "Debug: GEMINI_API_KEY present: #{@gemini_key ? 'yes' : 'no'}"
    puts "Debug: Available environment variables: #{ENV.keys.select { |k| k.include?('API') || k.include?('ANTHROPIC') }.join(', ')}"
  end

  def update_documentation(doc_file, changes, pr_summary)
    unless (@anthropic_key && !@anthropic_key.empty?) || (@gemini_key && !@gemini_key.empty?)
      puts "Warning: Neither ANTHROPIC_API_KEY nor GEMINI_API_KEY is set - skipping documentation generation"
      return nil
    end
    
    # Get existing documentation content if it exists
    existing_content = get_existing_doc_content(doc_file)
    puts "Updating #{doc_file} - existing content: #{existing_content&.length || 0} chars"
    
    # Generate prompt
    prompt = build_update_prompt(doc_file, existing_content, changes, pr_summary)
    puts "Generated prompt: #{prompt.length} chars"
    
    # Call appropriate AI API
    if @anthropic_key && !@anthropic_key.empty?
      puts "Using Anthropic Claude API..."
      content = call_anthropic_api(prompt)
    elsif @gemini_key && !@gemini_key.empty?
      puts "Using Google Gemini API..."
      content = call_gemini_api(prompt)
    end
    
    if content
      puts "AI generated #{content.length} characters"
      content
    else
      puts "No content generated"
      nil
    end
  rescue => e
    puts "Error updating documentation: #{e.message}"
    puts e.backtrace.first(3).join("\n")
    nil
  end

  private

  def call_anthropic_api(prompt)
    require 'anthropic'
    
    # Configure the gem properly
    Anthropic.configure do |config|
      config.access_token = @anthropic_key
    end
    
    client = Anthropic::Client.new
    
    response = client.messages(
      parameters: {
        model: 'claude-3-sonnet-20240229',
        max_tokens: 4000,
        messages: [{ role: 'user', content: prompt }]
      }
    )
    
    puts "Debug: Response class: #{response.class}"
    puts "Debug: Response methods: #{response.methods.grep(/content|text|body/).join(', ')}"
    
    # Handle different response formats
    if response.respond_to?(:dig)
      # Hash response
      if response.dig('content', 0, 'text')
        response.dig('content', 0, 'text')
      elsif response['choices'] && response['choices'][0] && response['choices'][0]['message']
        response['choices'][0]['message']['content']
      else
        puts "Debug: Response structure: #{response.inspect}"
        nil
      end
    elsif response.respond_to?(:content) && response.content.respond_to?(:first)
      # Object response
      response.content.first&.text
    elsif response.respond_to?(:body)
      # Raw response
      body = JSON.parse(response.body) rescue response.body
      body.dig('content', 0, 'text') if body.is_a?(Hash)
    else
      puts "Debug: Unknown response format: #{response.inspect}"
      nil
    end
  rescue => e
    puts "Anthropic API error: #{e.message}"
    puts "Debug: API key present: #{@anthropic_key ? 'yes' : 'no'}"
    puts "Debug: API key length: #{@anthropic_key&.length || 0}"
    nil
  end

  def call_gemini_api(prompt)
    require 'faraday'
    require 'json'
    
    base_url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent'
    
    conn = Faraday.new(url: base_url) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end

    payload = {
      contents: [
        {
          parts: [
            {
              text: prompt
            }
          ]
        }
      ]
    }

    response = conn.post do |req|
      req.url "?key=#{@gemini_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = payload
    end

    if response.body && response.body['candidates'] && response.body['candidates'].first
      content = response.body.dig('candidates', 0, 'content', 'parts', 0, 'text')
      content&.strip&.empty? ? nil : content
    else
      nil
    end
  rescue => e
    puts "Gemini API error: #{e.message}"
    nil
  end

  def get_existing_doc_content(doc_file)
    repo_name = ENV['GITHUB_REPOSITORY'] || 'user/repo'
    client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    
    begin
      file_content = client.contents(repo_name, path: doc_file)
      Base64.decode64(file_content[:content])
    rescue Octokit::NotFound
      # File doesn't exist, will create new one
      nil
    end
  end

  def build_update_prompt(doc_file, existing_content, changes, pr_summary)
    prompt = <<~PROMPT
      You are a technical documentation specialist. You need to update documentation based on code changes from a pull request.

      **Documentation File:** #{doc_file}
      **PR Summary:** #{pr_summary}

      **Existing Documentation:**
      #{existing_content || 'No existing documentation - create new content'}

      **Code Changes:**
      #{format_changes_for_prompt(changes)}

      **Instructions:**
      1. If updating existing documentation, preserve the existing structure and style
      2. Add or update sections based on the code changes
      3. Focus on user-facing changes, API modifications, and new features
      4. Use clear, concise language appropriate for developers
      5. Include code examples where relevant
      6. If creating new documentation, use a professional structure with proper headings

      Please provide the complete updated documentation content:
    PROMPT

    prompt
  end

  def format_changes_for_prompt(changes)
    formatted = []
    
    changes.each do |change|
      formatted << <<~CHANGE
        **File:** #{change[:filename]}
        **Status:** #{change[:status]}
        **Additions:** #{change[:additions]} lines
        **Deletions:** #{change[:deletions]} lines
        
        **Code Diff:**
        ```
        #{change[:patch]&.slice(0, 1000) || 'No patch available'}
        ```
        
      CHANGE
    end
    
    formatted.join("\n---\n")
  end
end