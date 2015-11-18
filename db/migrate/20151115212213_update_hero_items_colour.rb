class UpdateHeroItemsColour < ActiveRecord::Migration
  def change
    add_column :hero_items, :colour, :string
  end
end
