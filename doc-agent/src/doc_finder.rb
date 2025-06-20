require 'octokit'

class DocFinder
  def initialize
    @client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  end

  def find_relevant_docs(changes, repo_name)
    doc_files = []
    
    # Look for existing documentation patterns
    existing_docs = find_existing_docs(repo_name)
    
    changes.each do |change|
      # Map files to potential documentation
      potential_docs = map_file_to_docs(change[:filename], existing_docs)
      doc_files.concat(potential_docs)
    end
    
    # Add default documentation files if they don't exist
    doc_files << 'docs/API.md' if has_api_changes?(changes)
    doc_files << 'docs/FEATURES.md' if has_feature_changes?(changes)
    doc_files << 'README.md' if should_update_readme?(changes)
    
    doc_files.uniq
  end

  private

  def find_existing_docs(repo_name)
    docs = []
    
    # Check common documentation directories
    %w[docs/ doc/ documentation/].each do |dir|
      begin
        contents = @client.contents(repo_name, path: dir)
        contents.each do |item|
          docs << item[:path] if item[:name].end_with?('.md', '.rst', '.txt')
        end
      rescue Octokit::NotFound
        # Directory doesn't exist, continue
      end
    end
    
    # Check for README files
    %w[README.md README.rst README.txt].each do |readme|
      begin
        @client.contents(repo_name, path: readme)
        docs << readme
      rescue Octokit::NotFound
        # File doesn't exist, continue
      end
    end
    
    docs
  end

  def map_file_to_docs(filename, existing_docs)
    mapped_docs = []
    
    # API files -> API documentation
    if filename.include?('api') || filename.include?('controller')
      api_docs = existing_docs.select { |doc| doc.downcase.include?('api') }
      mapped_docs.concat(api_docs)
    end
    
    # Model files -> data/schema documentation
    if filename.include?('model') || filename.include?('schema')
      model_docs = existing_docs.select { |doc| doc.downcase.match?(/model|schema|data/) }
      mapped_docs.concat(model_docs)
    end
    
    # Service files -> architecture documentation
    if filename.include?('service') || filename.include?('lib')
      arch_docs = existing_docs.select { |doc| doc.downcase.match?(/architecture|service|component/) }
      mapped_docs.concat(arch_docs)
    end
    
    mapped_docs
  end

  def has_api_changes?(changes)
    changes.any? { |change| 
      change[:filename].include?('api') || 
      change[:filename].include?('controller') ||
      change[:patch]&.include?('def ') ||
      change[:patch]&.include?('route')
    }
  end

  def has_feature_changes?(changes)
    changes.any? { |change| 
      change[:additions] > 20 ||
      change[:filename].include?('feature') ||
      change[:patch]&.include?('class ') ||
      change[:patch]&.include?('module ')
    }
  end

  def should_update_readme?(changes)
    # Update README for significant changes or new major features
    total_additions = changes.sum { |change| change[:additions] }
    total_additions > 50 || changes.any? { |change| change[:status] == 'added' }
  end
end