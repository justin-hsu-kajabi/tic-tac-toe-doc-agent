class Achievement < ActiveRecord::Base
  validates :player_name, :achievement_type, :title, presence: true
  validates :achievement_type, inclusion: { 
    in: %w[first_win win_streak speed_demon undefeated comeback_king game_master] 
  }

  ACHIEVEMENT_DEFINITIONS = {
    'first_win' => {
      title: 'First Victory',
      description: 'Win your first game',
      icon: '🎉',
      condition: ->(stats) { stats[:wins] >= 1 }
    },
    'win_streak' => {
      title: 'Streak Master',
      description: 'Win 5 games in a row',
      icon: '🔥',
      condition: ->(stats) { stats[:current_streak] >= 5 }
    },
    'speed_demon' => {
      title: 'Speed Demon',
      description: 'Win a game in 3 moves',
      icon: '⚡',
      condition: ->(stats) { stats[:fastest_win] && stats[:fastest_win] <= 3 }
    },
    'undefeated' => {
      title: 'Undefeated Champion',
      description: 'Win 10 games without a loss',
      icon: '👑',
      condition: ->(stats) { stats[:wins] >= 10 && stats[:losses] == 0 }
    },
    'comeback_king' => {
      title: 'Comeback King',
      description: 'Win 50% of games after losing streak',
      icon: '💪',
      condition: ->(stats) { stats[:total_games] >= 20 && stats[:win_rate] >= 50 }
    },
    'game_master' => {
      title: 'Game Master',
      description: 'Play 100 games',
      icon: '🎮',
      condition: ->(stats) { stats[:total_games] >= 100 }
    }
  }.freeze

  def self.check_and_award(player_name, leaderboard_stats)
    player_achievements = where(player_name: player_name).pluck(:achievement_type)
    new_achievements = []

    ACHIEVEMENT_DEFINITIONS.each do |type, definition|
      next if player_achievements.include?(type)

      stats_hash = {
        wins: leaderboard_stats.wins,
        losses: leaderboard_stats.losses,
        total_games: leaderboard_stats.total_games,
        win_rate: leaderboard_stats.win_rate,
        current_streak: leaderboard_stats.current_win_streak,
        fastest_win: leaderboard_stats.fastest_win_moves
      }

      if definition[:condition].call(stats_hash)
        achievement = create!(
          player_name: player_name,
          achievement_type: type,
          title: definition[:title],
          description: definition[:description],
          icon: definition[:icon],
          earned_at: Time.current
        )
        new_achievements << achievement
      end
    end

    new_achievements
  end

  def self.for_player(player_name)
    where(player_name: player_name).order(:earned_at)
  end

  def self.recent_achievements(limit = 10)
    order(earned_at: :desc).limit(limit)
  end
end