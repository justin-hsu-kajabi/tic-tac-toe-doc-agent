class Room < ActiveRecord::Base
  has_many :games, dependent: :destroy
  has_many :players, dependent: :destroy
  
  validates :code, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[waiting active completed] }
  
  before_create :generate_room_code
  
  def full?
    players.count >= 2
  end
  
  def ready_to_start?
    players.count == 2 && status == 'waiting'
  end
  
  def current_game
    games.where(status: 'playing').first
  end
  
  def start_new_game!
    return false unless ready_to_start?
    
    game = games.create!(
      player_x: players.first.name,
      player_o: players.second.name,
      current_player: 'X'
    )
    
    update!(status: 'active')
    game
  end
  
  def add_player(name, session_id)
    return false if full?
    
    players.create!(
      name: name,
      session_id: session_id,
      symbol: players.count == 0 ? 'X' : 'O'
    )
  end
  
  private
  
  def generate_room_code
    self.code = SecureRandom.alphanumeric(6).upcase
  end
end