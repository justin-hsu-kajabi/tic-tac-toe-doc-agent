class CreateThemes < ActiveRecord::Migration[7.0]
  def up
    create_table :themes do |t|
      t.string :name, null: false
      t.string :style_type, null: false
      t.text :description
      t.string :primary_color, null: false
      t.string :secondary_color, null: false
      t.string :accent_color, null: false
      t.string :board_color, null: false
      t.string :cell_color, null: false
      t.string :text_color, null: false
      t.string :hover_color, null: false
      t.boolean :is_default, default: false
      t.timestamps
    end

    add_index :themes, :name, unique: true
    add_index :themes, :style_type, unique: true
    add_index :themes, :is_default
  end

  def down
    drop_table :themes
  end
end