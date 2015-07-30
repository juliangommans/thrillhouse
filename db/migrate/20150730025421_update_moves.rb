class UpdateMoves < ActiveRecord::Migration
  def change
    rename_column :moves, :type, :category
    rename_column :characters, :type, :breed
  end
end
