class GameStatistic < ActiveRecord::Base
  validates :stat_date, presence: true, uniqueness: true
  
  def self.today
    find_or_create_by(stat_date: Date.current)
  end
  
  def self.update_for_game(game)
    stat = today
    
    stat.total_games += 1
    
    case game.game_type
    when 'multiplayer'
      stat.multiplayer_games += 1
    else
      stat.solo_games += 1
    end
    
    if game.finished_at && game.started_at
      duration = (game.finished_at - game.started_at) / 1.minute
      stat.average_game_duration = calculate_new_average(
        stat.average_game_duration, 
        duration, 
        stat.total_games
      )
    end
    
    # Track move statistics
    if game.move_count > 0
      if stat.fastest_win_moves.nil? || (game.winner && game.move_count < stat.fastest_win_moves)
        stat.fastest_win_moves = game.move_count if game.winner
      end
      
      stat.longest_game_moves = [stat.longest_game_moves, game.move_count].max
    end
    
    # Track win/loss/draw statistics
    case game.status
    when 'X_wins', 'O_wins'
      stat.total_wins += 1
    when 'draw'
      stat.total_draws += 1
    else
      stat.total_losses += 1
    end
    
    stat.save!
    stat
  end
  
  def win_rate
    return 0.0 if total_games == 0
    (total_wins.to_f / total_games * 100).round(2)
  end
  
  def draw_rate
    return 0.0 if total_games == 0
    (total_draws.to_f / total_games * 100).round(2)
  end
  
  def multiplayer_percentage
    return 0.0 if total_games == 0
    (multiplayer_games.to_f / total_games * 100).round(2)
  end
  
  def self.weekly_summary
    week_ago = 7.days.ago.to_date
    where(stat_date: week_ago..Date.current)
      .order(:stat_date)
  end
  
  def self.aggregate_stats(start_date = 30.days.ago.to_date, end_date = Date.current)
    stats = where(stat_date: start_date..end_date)
    
    {
      total_games: stats.sum(:total_games),
      total_wins: stats.sum(:total_wins),
      total_draws: stats.sum(:total_draws),
      total_losses: stats.sum(:total_losses),
      multiplayer_games: stats.sum(:multiplayer_games),
      solo_games: stats.sum(:solo_games),
      average_duration: stats.average(:average_game_duration)&.round(2) || 0.0,
      fastest_win: stats.where.not(fastest_win_moves: nil).minimum(:fastest_win_moves),
      longest_game: stats.maximum(:longest_game_moves)
    }
  end
  
  private
  
  def self.calculate_new_average(current_avg, new_value, total_count)
    return new_value if total_count == 1
    ((current_avg * (total_count - 1)) + new_value) / total_count
  end
end