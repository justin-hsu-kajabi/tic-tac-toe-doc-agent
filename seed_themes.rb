#!/usr/bin/env ruby

require 'active_record'

# Set up database connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.join(__dir__, 'db', 'development.sqlite3')
)

require_relative 'app/models/theme'

puts "🎨 Seeding default themes..."

# Create default themes if they don't exist
Theme.create_default_themes

puts "✅ Default themes created successfully!"

# Show all themes
puts "\n🌈 Available themes:"
Theme.all.each do |theme|
  status = theme.is_default? ? " (Default)" : ""
  puts "  • #{theme.name}#{status} - #{theme.description}"
  puts "    Colors: #{theme.primary_color}, #{theme.secondary_color}, #{theme.accent_color}"
end

puts "\n💡 Themes are now available at /api/themes"