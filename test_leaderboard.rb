#!/usr/bin/env ruby

# Simple test script to demonstrate leaderboard functionality
# Run with: ruby test_leaderboard.rb

require_relative 'app/models/game'
require_relative 'app/models/room'
require_relative 'app/models/player'
require_relative 'app/models/leaderboard'
require_relative 'app/models/achievement'
require 'active_record'

# Set up database connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.join(__dir__, 'db', 'development.sqlite3')
)

puts "🎮 Leaderboard System Demo"
puts "=" * 40

# Create some test data
puts "\n📊 Creating sample leaderboard data..."

# Sample players and their performance
players_data = [
  { name: "Alice", wins: 15, losses: 5, draws: 2 },
  { name: "Bob", wins: 12, losses: 8, draws: 3 },
  { name: "Charlie", wins: 20, losses: 3, draws: 1 },
  { name: "Diana", wins: 8, losses: 12, draws: 4 },
  { name: "Eve", wins: 25, losses: 10, draws: 5 }
]

players_data.each do |data|
  leaderboard = Leaderboard.find_or_create_by(player_name: data[:name])
  leaderboard.update!(
    wins: data[:wins],
    losses: data[:losses],
    draws: data[:draws],
    total_games: data[:wins] + data[:losses] + data[:draws],
    current_win_streak: rand(0..5),
    best_win_streak: rand(5..15),
    fastest_win_moves: rand(3..7),
    last_game_at: rand(1..30).days.ago
  )
end

puts "✅ Sample data created!"

# Demonstrate leaderboard queries
puts "\n🏆 TOP PLAYERS BY WINS:"
puts "-" * 30
Leaderboard.top_players(5).each_with_index do |player, index|
  puts "#{index + 1}. #{player.player_name} - #{player.wins} wins (#{player.win_rate}%)"
end

puts "\n📈 BEST WIN RATES (min 5 games):"
puts "-" * 35
Leaderboard.by_win_rate(5).each_with_index do |player, index|
  puts "#{index + 1}. #{player.player_name} - #{player.win_rate}% (#{player.wins}/#{player.total_games})"
end

puts "\n🎯 MOST ACTIVE PLAYERS:"
puts "-" * 25
Leaderboard.by_total_games(5).each_with_index do |player, index|
  puts "#{index + 1}. #{player.player_name} - #{player.total_games} games"
end

puts "\n🔥 CURRENT WIN STREAKS:"
puts "-" * 25
Leaderboard.order(current_win_streak: :desc).limit(3).each_with_index do |player, index|
  puts "#{index + 1}. #{player.player_name} - #{player.current_win_streak} wins in a row"
end

puts "\n⚡ FASTEST WINS:"
puts "-" * 18
Leaderboard.where.not(fastest_win_moves: nil).order(:fastest_win_moves).limit(3).each_with_index do |player, index|
  puts "#{index + 1}. #{player.player_name} - #{player.fastest_win_moves} moves"
end

# Show detailed stats for one player
puts "\n👤 DETAILED PLAYER STATS (Charlie):"
puts "-" * 35
charlie = Leaderboard.find_by(player_name: "Charlie")
if charlie
  puts "Total Games: #{charlie.total_games}"
  puts "Wins: #{charlie.wins}"
  puts "Losses: #{charlie.losses}"
  puts "Draws: #{charlie.draws}"
  puts "Win Rate: #{charlie.win_rate}%"
  puts "Current Streak: #{charlie.current_win_streak}"
  puts "Best Streak: #{charlie.best_win_streak}"
  puts "Fastest Win: #{charlie.fastest_win_moves} moves"
  puts "Rank by Wins: ##{charlie.rank_by_wins}"
  puts "Rank by Win Rate: ##{charlie.rank_by_win_rate}"
  puts "Last Game: #{charlie.last_game_at&.strftime('%Y-%m-%d %H:%M')}"
end

# Test achievement system
puts "\n🏆 TESTING ACHIEVEMENT SYSTEM:"
puts "-" * 35

# Create some sample achievements
alice = Leaderboard.find_by(player_name: "Alice")
if alice
  # Manually create some achievements for demonstration
  Achievement.find_or_create_by(
    player_name: "Alice",
    achievement_type: "first_win"
  ) do |achievement|
    definition = Achievement::ACHIEVEMENT_DEFINITIONS['first_win']
    achievement.title = definition[:title]
    achievement.description = definition[:description]
    achievement.icon = definition[:icon]
    achievement.earned_at = 5.days.ago
  end

  Achievement.find_or_create_by(
    player_name: "Charlie",
    achievement_type: "speed_demon"
  ) do |achievement|
    definition = Achievement::ACHIEVEMENT_DEFINITIONS['speed_demon']
    achievement.title = definition[:title]
    achievement.description = definition[:description]
    achievement.icon = definition[:icon]
    achievement.earned_at = 2.days.ago
  end
end

# Show recent achievements
puts "Recent achievements:"
Achievement.recent_achievements(5).each_with_index do |achievement, index|
  puts "#{index + 1}. #{achievement.icon} #{achievement.player_name} - #{achievement.title}"
  puts "   #{achievement.description} (#{achievement.earned_at.strftime('%Y-%m-%d')})"
end

puts "\n📋 AVAILABLE ACHIEVEMENT TYPES:"
puts "-" * 35
Achievement::ACHIEVEMENT_DEFINITIONS.each do |type, definition|
  puts "#{definition[:icon]} #{definition[:title]} - #{definition[:description]}"
end

puts "\n" + "=" * 40
puts "🎮 Enhanced leaderboard system with achievements is working!"
puts "Visit /leaderboard.html to see the web interface with achievements."
puts "API endpoints available:"
puts "  • GET /api/leaderboard"
puts "  • GET /api/leaderboard/Alice" 
puts "  • GET /api/leaderboard/stats/summary"
puts "  • GET /api/achievements"
puts "  • GET /api/achievements/Alice"
puts "  • GET /api/achievements/definitions/all"