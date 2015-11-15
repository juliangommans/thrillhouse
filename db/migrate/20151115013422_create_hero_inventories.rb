class CreateHeroInventories < ActiveRecord::Migration
  def change
    create_table :hero_inventories do |t|
      t.belongs_to :heroes, index: true
      t.belongs_to :hero_items, index: true
      t.timestamps
    end
  end
end
