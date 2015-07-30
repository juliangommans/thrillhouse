class CreateBuffs < ActiveRecord::Migration
  def change
    create_table :buffs do |t|
      t.string :name
      t.string :buff_type
      t.string :stat
      t.string :type
      t.integer :value
      t.integer :stacks
      t.integer :duration
      t.timestamps
    end
  end
end
