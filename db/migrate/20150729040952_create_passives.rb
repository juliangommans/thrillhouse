class CreatePassives < ActiveRecord::Migration
  def change
    create_table :passives do |t|

      t.timestamps
    end
  end
end
