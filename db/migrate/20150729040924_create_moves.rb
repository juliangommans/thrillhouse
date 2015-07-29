class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|

      t.timestamps
    end
  end
end
