class AddCriticalToMoves < ActiveRecord::Migration
  def change
    add_column :moves, :critical, :boolean, default: false
    add_column :moves, :critical_damage, :decimal
  end
end
