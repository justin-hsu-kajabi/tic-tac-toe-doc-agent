class CreateAchievements < ActiveRecord::Migration[7.0]
  def up
    create_table :achievements do |t|
      t.string :player_name, null: false
      t.string :achievement_type, null: false
      t.string :title, null: false
      t.text :description
      t.string :icon
      t.datetime :earned_at, null: false
      t.timestamps
    end

    add_index :achievements, :player_name
    add_index :achievements, :achievement_type
    add_index :achievements, :earned_at
    add_index :achievements, [:player_name, :achievement_type], unique: true
  end

  def down
    drop_table :achievements
  end
end