require 'anthropic'
require 'base64'
require 'octokit'

class DocUpdater
  def initialize
    @client = Anthropic::Client.new(api_key: ENV['ANTHROPIC_API_KEY'])
  end

  def update_documentation(doc_file, changes, pr_summary)
    # Get existing documentation content if it exists
    existing_content = get_existing_doc_content(doc_file)
    
    # Generate prompt for Claude
    prompt = build_update_prompt(doc_file, existing_content, changes, pr_summary)
    
    # Call Claude API
    response = @client.messages(
      model: 'claude-3-sonnet-20240229',
      max_tokens: 4000,
      messages: [{ role: 'user', content: prompt }]
    )
    
    response.content.first['text']
  rescue => e
    puts "Error updating documentation: #{e.message}"
    nil
  end

  private

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