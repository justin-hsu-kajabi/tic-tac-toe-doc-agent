class Player < ActiveRecord::Base
  belongs_to :room, optional: true
  has_many :games
  
  validates :name, presence: true
  validates :session_id, presence: true, uniqueness: true, allow_nil: true
  validates :symbol, inclusion: { in: %w[X O] }, allow_nil: true
  validates :wins, :losses, :draws, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  scope :in_room, ->(room_code) { joins(:room).where(rooms: { code: room_code }) }
  
  # Multiplayer functionality
  def opponent
    return nil unless room
    room.players.where.not(id: id).first
  end
  
  def is_turn?(game)
    game.current_player == symbol
  end
  
  # Statistics functionality
  def total_games
    (wins || 0) + (losses || 0) + (draws || 0)
  end
  
  def win_rate
    return 0.0 if total_games == 0
    ((wins || 0).to_f / total_games * 100).round(2)
  end
  
  def record_win!
    increment!(:wins)
  end
  
  def record_loss!
    increment!(:losses)
  end
  
  def record_draw!
    increment!(:draws)
  end
end