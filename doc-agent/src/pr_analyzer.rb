require 'octokit'
require 'json'

class PRAnalyzer
  def initialize
    @client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  end

  def analyze_pr(pr_data, repo_name)
    files_changed = get_pr_files(repo_name, pr_data['number'])
    
    analysis = {
      needs_doc_update: false,
      changes: [],
      summary: pr_data['title'],
      files_changed: files_changed.map { |f| f[:filename] }
    }

    files_changed.each do |file|
      change_analysis = analyze_file_changes(file)
      if change_analysis[:significant]
        analysis[:needs_doc_update] = true
        analysis[:changes] << change_analysis
      end
    end

    analysis
  end

  private

  def get_pr_files(repo_name, pr_number)
    @client.pull_request_files(repo_name, pr_number)
  rescue => e
    puts "Error fetching PR files: #{e.message}"
    []
  end

  def analyze_file_changes(file)
    {
      filename: file[:filename],
      status: file[:status],
      additions: file[:additions],
      deletions: file[:deletions],
      patch: file[:patch],
      significant: is_significant_change?(file)
    }
  end

  def is_significant_change?(file)
    # Check if this is a significant change that needs documentation
    return true if file[:filename].match?(/\.(rb|js|py|java|go|rs)$/)
    return true if file[:additions] > 10
    return true if file[:filename].include?('api') || file[:filename].include?('controller')
    return true if file[:patch]&.include?('def ') || file[:patch]&.include?('function ')
    return true if file[:patch]&.include?('class ') || file[:patch]&.include?('module ')
    
    false
  end
end