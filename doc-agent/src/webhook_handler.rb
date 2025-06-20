require 'json'
require 'octokit'
require_relative 'pr_analyzer'
require_relative 'doc_finder'
require_relative 'doc_updater'

class WebhookHandler
  def self.process_pr(payload)
    return unless payload['pull_request']

    pr_data = payload['pull_request']
    repo_name = payload['repository']['full_name']
    
    puts "Debug: PR data keys: #{pr_data.keys.join(', ')}"
    puts "Debug: PR user: #{pr_data['user']&.inspect}"
    
    # Skip if this is a documentation-only PR created by the doc agent
    pr_title = pr_data['title'] || ''
    pr_user = pr_data.dig('user', 'login') || ''
    
    if pr_title.include?('📚 Update documentation') || 
       pr_title.include?('doc-update') ||
       pr_user == 'github-actions[bot]'
      puts "Skipping doc agent analysis for documentation-only PR: #{pr_title}"
      return
    end
    
    puts "Processing PR ##{pr_data['number']} in #{repo_name}: #{pr_title}"
    
    analyzer = PRAnalyzer.new
    doc_finder = DocFinder.new
    doc_updater = DocUpdater.new
    
    # Analyze the PR for documentation triggers
    analysis = analyzer.analyze_pr(pr_data, repo_name)
    puts "Analysis complete. Needs doc update: #{analysis[:needs_doc_update]}"
    puts "Found #{analysis[:changes].length} significant changes"
    
    if analysis[:needs_doc_update]
      # Find relevant documentation files
      doc_files = doc_finder.find_relevant_docs(analysis[:changes], repo_name)
      puts "Found #{doc_files.length} documentation files to update: #{doc_files.join(', ')}"
      
      # Generate documentation updates
      doc_files.each do |doc_file|
        puts "Updating #{doc_file}..."
        updated_content = doc_updater.update_documentation(
          doc_file, 
          analysis[:changes], 
          analysis[:summary]
        )
        
        if updated_content
          puts "Creating PR for #{doc_file}..."
          create_doc_update_pr(repo_name, doc_file, updated_content, pr_data)
        else
          puts "No content generated for #{doc_file}"
        end
      end
    else
      puts "No documentation updates needed"
    end
  rescue => e
    puts "Error processing PR webhook: #{e.message}"
    puts e.backtrace.first(5).join("\n")
    raise e
  end

  private

  def self.create_doc_update_pr(repo_name, doc_file, content, original_pr)
    client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    
    branch_name = "doc-update-pr-#{original_pr['number']}-#{Time.now.to_i}"
    base_branch = original_pr['base']['ref']
    
    # Create new branch
    base_sha = client.ref(repo_name, "heads/#{base_branch}")[:object][:sha]
    client.create_ref(repo_name, "heads/#{branch_name}", base_sha)
    
    # Update file
    begin
      existing_file = client.contents(repo_name, path: doc_file, ref: branch_name)
      client.update_contents(
        repo_name,
        doc_file,
        "Update documentation for PR ##{original_pr['number']}",
        existing_file[:sha],
        content,
        branch: branch_name
      )
    rescue Octokit::NotFound
      client.create_contents(
        repo_name,
        doc_file,
        "Create documentation for PR ##{original_pr['number']}",
        content,
        branch: branch_name
      )
    end
    
    # Create PR
    client.create_pull_request(
      repo_name,
      base_branch,
      branch_name,
      "📚 Update documentation for PR ##{original_pr['number']}",
      generate_pr_body(original_pr, doc_file)
    )
  end

  def self.generate_pr_body(original_pr, doc_file)
    <<~BODY
      ## 🤖 Automated Documentation Update
      
      This PR updates documentation based on changes in PR ##{original_pr['number']}: "#{original_pr['title']}"
      
      ### Changes Made
      - Updated `#{doc_file}` to reflect new functionality
      - Generated using AI analysis of code changes
      
      ### Related PR
      - #{original_pr['html_url']}
      
      ---
      
      > **Note:** This is an automated documentation update. The doc agent will **not** process this PR to avoid infinite loops.
      
      🤖 Generated with AI Doc Agent
    BODY
  end
end