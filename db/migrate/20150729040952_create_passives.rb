class CreatePassives < ActiveRecord::Migration
  def change
    create_table :passives do |t|
      t.string :name
      t.belongs_to :character , index: true
      t.timestamps
    end
  end
end
