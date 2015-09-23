class UpdateToDecimal < ActiveRecord::Migration
  def change
    change_column :characters, :critical_strike_power, :decimal
  end
end
