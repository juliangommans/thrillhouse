class UpdateHeroInventory < ActiveRecord::Migration
  def change
    add_column :hero_inventories, :spell, :string, default: ""
  end
end
