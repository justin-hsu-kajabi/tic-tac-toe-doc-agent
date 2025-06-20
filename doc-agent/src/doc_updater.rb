require 'faraday'
require 'base64'
require 'octokit'
require 'json'

class DocUpdater
  def initialize
    @api_key = ENV['GEMINI_API_KEY']
    @base_url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent'
  end

  def update_documentation(doc_file, changes, pr_summary)
    if @api_key.nil? || @api_key.empty?
      puts "Warning: GEMINI_API_KEY not set or empty"
      return nil
    end
    
    puts "Gemini API key present: #{@api_key[0..10]}..."
    
    # Get existing documentation content if it exists
    existing_content = get_existing_doc_content(doc_file)
    puts "Existing content length: #{existing_content&.length || 0} characters"
    
    # Generate prompt for Gemini
    prompt = build_update_prompt(doc_file, existing_content, changes, pr_summary)
    puts "Generated prompt length: #{prompt.length} characters"
    
    # Call Gemini API
    puts "Calling Gemini API..."
    response = call_gemini_api(prompt)
    
    if response
      puts "Gemini response received"
      if response['error']
        puts "Gemini API error: #{response['error']['message']}"
        return nil
      end
      
      if response['candidates'] && response['candidates'].first
        content = response.dig('candidates', 0, 'content', 'parts', 0, 'text')
        if content&.strip&.empty?
          puts "Gemini returned empty content"
          nil
        else
          puts "Gemini generated #{content.length} characters"
          content
        end
      else
        puts "No candidates in Gemini response: #{response.inspect}"
        nil
      end
    else
      puts "No response from Gemini API"
      nil
    end
  rescue => e
    puts "Error updating documentation with Gemini: #{e.message}"
    puts e.backtrace.first(3).join("\n")
    nil
  end

  private

  def call_gemini_api(prompt)
    conn = Faraday.new(url: @base_url) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.response :logger # Add logging
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

    puts "Sending request to Gemini API..."
    response = conn.post do |req|
      req.url "?key=#{@api_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = payload
    end

    puts "Response status: #{response.status}"
    response.body
  rescue => e
    puts "API call failed: #{e.message}"
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