class Player < ActiveRecord::Base
  has_many :games
  
  validates :name, presence: true, uniqueness: true
  validates :wins, :losses, :draws, numericality: { greater_than_or_equal_to: 0 }
  
  def total_games
    wins + losses + draws
  end
  
  def win_rate
    return 0.0 if total_games == 0
    (wins.to_f / total_games * 100).round(2)
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