class UpdateHeroItems < ActiveRecord::Migration
  def change
    add_column :hero_items, :spell_stat, :string, default: ""
    add_column :hero_items, :change, :decimal, default: 1
  end
end
