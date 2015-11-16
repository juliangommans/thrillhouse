class UpdateHeroItemsType < ActiveRecord::Migration
  def change
    add_column :hero_items, :category, :string
  end
end
