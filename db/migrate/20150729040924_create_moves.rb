class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.string :name
      t.string :type
      t.string :realm
      t.string :element
      t.integer :power
      t.integer :cost
      t.integer :cooldown
      t.integer :rank
      t.integer :tier
      t.timestamps
    end
  end
end
