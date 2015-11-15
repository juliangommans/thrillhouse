class CreateLilRpgMapEditor < ActiveRecord::Migration
  def change
    create_table :lil_rpg_map_editors do |t|
      t.string :name
      t.integer :size
      t.text :map
      t.timestamps
    end
  end
end
