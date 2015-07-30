class CreateEffects < ActiveRecord::Migration
  def change
    create_table :effects do |t|
      t.string :name
      t.belongs_to :buff, index: true
      t.belongs_to :move, index: true
      t.timestamps
    end
  end
end
