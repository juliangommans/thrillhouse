class UpdateItemsSpells < ActiveRecord::Migration
  def change
    add_column :hero_items, :spell, :string, default: ""
  end
end
