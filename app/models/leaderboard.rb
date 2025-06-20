class Leaderboard < ActiveRecord::Base
  validates :player_name, presence: true, uniqueness: true
  validates :total_games, :wins, :losses, :draws, numericality: { greater_than_or_equal_to: 0 }

  def self.update_for_game(game)
    return unless game.respond_to?(:finished_at) && game.finished_at

    # Update leaderboard for multiplayer games
    if game.room && game.room.players.count == 2
      game.room.players.each do |player|
        leaderboard_entry = find_or_create_by(player_name: player.name)
        leaderboard_entry.increment_stats_for_game(game, player.symbol)
      end
    end
  end

  def increment_stats_for_game(game, player_symbol)
    self.total_games += 1

    case game.status
    when "#{player_symbol}_wins"
      self.wins += 1
    when 'draw'
      self.draws += 1
    else
      self.losses += 1
    end

    # Update streak tracking
    if game.status == "#{player_symbol}_wins"
      self.current_win_streak = (self.current_win_streak || 0) + 1
      self.best_win_streak = [self.best_win_streak || 0, self.current_win_streak].max
    else
      self.current_win_streak = 0
    end

    # Update fastest win if applicable
    if game.status == "#{player_symbol}_wins" && game.respond_to?(:move_count)
      current_fastest = self.fastest_win_moves || Float::INFINITY
      self.fastest_win_moves = [current_fastest, game.move_count].min if game.move_count
    end

    # Update last game timestamp
    self.last_game_at = Time.current

    save!
  end

  def win_rate
    return 0.0 if total_games == 0
    (wins.to_f / total_games * 100).round(2)
  end

  def self.top_players(limit = 10)
    order(wins: :desc, win_rate: :desc).limit(limit)
  end

  def self.by_win_rate(limit = 10)
    where('total_games >= ?', 5) # Minimum games for ranking
      .order(Arel.sql('CAST(wins AS FLOAT) / total_games DESC'))
      .limit(limit)
  end

  def self.by_total_games(limit = 10)
    order(total_games: :desc).limit(limit)
  end

  def rank_by_wins
    Leaderboard.where('wins > ?', wins).count + 1
  end

  def rank_by_win_rate
    return nil if total_games < 5
    Leaderboard.where('total_games >= ? AND CAST(wins AS FLOAT) / total_games > ?', 5, win_rate / 100.0).count + 1
  end
end