class CreateCharacters < ActiveRecord::Migration
  def change
    create_table :characters do |t|
      t.string :name
      t.string :type
      t.integer :stats
      t.integer :health
      t.integer :attack
      t.integer :defense
      t.integer :energy
      t.integer :resilience
      t.integer :speed
      t.integer :action_points
      t.integer :critical_strike_chance
      t.integer :critical_strike_power
      t.integer :combo_points
      t.string :specialisation
      t.string :nature
      t.timestamps
    end
  end
end
