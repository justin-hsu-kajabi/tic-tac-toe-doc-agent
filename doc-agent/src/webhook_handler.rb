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
      
      # Generate documentation updates for all files
      doc_updates = {}
      doc_files.each do |doc_file|
        puts "Updating #{doc_file}..."
        updated_content = doc_updater.update_documentation(
          doc_file, 
          analysis[:changes], 
          analysis[:summary]
        )
        
        if updated_content
          doc_updates[doc_file] = updated_content
          puts "Generated content for #{doc_file}: #{updated_content.length} characters"
        else
          puts "No content generated for #{doc_file}"
        end
      end
      
      # Create single PR with all documentation updates
      if doc_updates.any?
        puts "Creating single PR with #{doc_updates.length} documentation updates..."
        create_combined_doc_update_pr(repo_name, doc_updates, pr_data)
      else
        puts "No documentation content was generated"
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

  def self.create_combined_doc_update_pr(repo_name, doc_updates, original_pr)
    client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    
    branch_name = "doc-update-pr-#{original_pr['number']}-#{Time.now.to_i}"
    base_branch = original_pr['base']['ref']
    
    # Create new branch
    base_sha = client.ref(repo_name, "heads/#{base_branch}")[:object][:sha]
    client.create_ref(repo_name, "heads/#{branch_name}", base_sha)
    
    # Update all documentation files in the same branch
    doc_updates.each do |doc_file, content|
      puts "Committing update to #{doc_file}..."
      begin
        existing_file = client.contents(repo_name, path: doc_file, ref: branch_name)
        client.update_contents(
          repo_name,
          doc_file,
          "Update #{doc_file} for PR ##{original_pr['number']}",
          existing_file[:sha],
          content,
          branch: branch_name
        )
      rescue Octokit::NotFound
        client.create_contents(
          repo_name,
          doc_file,
          "Create #{doc_file} for PR ##{original_pr['number']}",
          content,
          branch: branch_name
        )
      end
    end
    
    # Create single PR with all updates
    client.create_pull_request(
      repo_name,
      base_branch,
      branch_name,
      "📚 Update documentation for PR ##{original_pr['number']}",
      generate_combined_pr_body(original_pr, doc_updates.keys)
    )
  end

  def self.generate_combined_pr_body(original_pr, doc_files)
    files_list = doc_files.map { |file| "- `#{file}`" }.join("\n")
    
    <<~BODY
      ## 🤖 Automated Documentation Update
      
      This PR updates documentation based on changes in PR ##{original_pr['number']}: "#{original_pr['title']}"
      
      ### Files Updated
      #{files_list}
      
      ### Changes Made
      - Updated documentation to reflect new functionality and API changes
      - Generated using AI analysis of code changes from the original PR
      - Ensures documentation stays current with latest development
      
      ### Related PR
      - #{original_pr['html_url']}
      
      ---
      
      > **Note:** This is an automated documentation update. The doc agent will **not** process this PR to avoid infinite loops.
      
      🤖 Generated with AI Doc Agent
    BODY
  end
end