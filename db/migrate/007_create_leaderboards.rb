class CreateLeaderboards < ActiveRecord::Migration[7.0]
  def up
    create_table :leaderboards do |t|
      t.string :player_name, null: false
      t.integer :total_games, default: 0
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :draws, default: 0
      t.integer :current_win_streak, default: 0
      t.integer :best_win_streak, default: 0
      t.integer :fastest_win_moves
      t.datetime :last_game_at
      t.timestamps
    end

    add_index :leaderboards, :player_name, unique: true
    add_index :leaderboards, :wins
    add_index :leaderboards, :total_games
    add_index :leaderboards, [:wins, :total_games]
  end

  def down
    drop_table :leaderboards
  end
end