class AddColumnToMoves < ActiveRecord::Migration
  def change
    add_column :moves, :bonus, :boolean, default: false
  end
end
