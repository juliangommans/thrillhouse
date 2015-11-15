class CreateHeroItems < ActiveRecord::Migration
  def change
    create_table :hero_items do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end
end
