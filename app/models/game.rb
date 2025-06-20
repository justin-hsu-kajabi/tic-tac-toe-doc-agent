class Game < ActiveRecord::Base
  belongs_to :room, optional: true
  serialize :board, type: Array
  
  before_create :set_game_start_time
  after_update :update_statistics, if: :game_finished?

  def make_move(position, player_session_id = nil)
    return false if position < 0 || position > 8
    return false if board[position] || status != 'playing'
    
    # For multiplayer games, validate turn
    if room && player_session_id
      player = room.players.find_by(session_id: player_session_id)
      return false unless player&.is_turn?(self)
    end

    self.board[position] = current_player
    
    # Only track move count if column exists
    if respond_to?(:move_count=)
      self.move_count = (move_count || 0) + 1
    end
    
    if winner
      self.status = "#{winner}_wins"
      if respond_to?(:winner_player=)
        self.winner_player = winner
      end
      if respond_to?(:finished_at=)
        self.finished_at = Time.current
      end
    elsif board.all? { |cell| !cell.nil? }
      self.status = 'draw'
      if respond_to?(:finished_at=)
        self.finished_at = Time.current
      end
    else
      self.current_player = current_player == 'X' ? 'O' : 'X'
    end

    save
  end

  def winner
    winning_combinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], # rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], # columns
      [0, 4, 8], [2, 4, 6]             # diagonals
    ]

    winning_combinations.each do |combo|
      if board[combo[0]] && 
         board[combo[0]] == board[combo[1]] && 
         board[combo[1]] == board[combo[2]]
        return board[combo[0]]
      end
    end

    nil
  end
  
  def duration_in_minutes
    return 0 unless respond_to?(:finished_at) && respond_to?(:started_at)
    return 0 unless finished_at && started_at
    ((finished_at - started_at) / 1.minute).round(2)
  end
  
  def game_finished?
    status != 'playing'
  end
  
  private
  
  def set_game_start_time
    # Only set if the column exists (for backward compatibility)
    if respond_to?(:started_at=)
      self.started_at = Time.current
    end
    
    if respond_to?(:game_type=)
      self.game_type = room ? 'multiplayer' : 'solo'
    end
  end
  
  def update_statistics
    # Only update statistics if we have the necessary columns
    return unless respond_to?(:finished_at) && respond_to?(:finished_at_changed?)
    return unless finished_at_changed? && finished_at.present?
    
    # Only call if GameStatistic class exists
    if defined?(GameStatistic)
      GameStatistic.update_for_game(self)
    end
    
    # Update leaderboard if available
    if defined?(Leaderboard)
      Leaderboard.update_for_game(self)
    end
  end
end