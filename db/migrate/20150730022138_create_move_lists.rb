class CreateMoveLists < ActiveRecord::Migration
  def change
    create_table :move_lists do |t|
      t.belongs_to :move, index: true
      t.belongs_to :character, index: true
      t.timestamps
    end
  end
end
