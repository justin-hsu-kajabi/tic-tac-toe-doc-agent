class Player < ActiveRecord::Base
  belongs_to :room
  
  validates :name, presence: true
  validates :session_id, presence: true, uniqueness: true
  validates :symbol, inclusion: { in: %w[X O] }
  
  scope :in_room, ->(room_code) { joins(:room).where(rooms: { code: room_code }) }
  
  def opponent
    room.players.where.not(id: id).first
  end
  
  def is_turn?(game)
    game.current_player == symbol
  end
end