class AddColumnToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :total_combo_points, :integer, default: 5
    add_column :characters, :total_critical_strike_points, :integer, default: 10
  end
end
