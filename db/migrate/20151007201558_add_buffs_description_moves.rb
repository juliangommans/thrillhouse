class AddBuffsDescriptionMoves < ActiveRecord::Migration
  def change
    add_column :moves, :stat, :string
    add_column :moves, :stat_target, :string
    add_column :moves, :description, :string
  end
end
