class Game < ActiveRecord::Base
  belongs_to :room, optional: true
  serialize :board, type: Array

  def make_move(position, player_session_id = nil)
    return false if position < 0 || position > 8
    return false if board[position] || status != 'playing'
    
    # For multiplayer games, validate turn
    if room && player_session_id
      player = room.players.find_by(session_id: player_session_id)
      return false unless player&.is_turn?(self)
    end

    self.board[position] = current_player
    
    if winner
      self.status = "#{winner}_wins"
    elsif board.all? { |cell| !cell.nil? }
      self.status = 'draw'
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
end