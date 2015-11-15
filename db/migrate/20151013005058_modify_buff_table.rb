class ModifyBuffTable < ActiveRecord::Migration
  def change
    change_column :buffs, :value, :decimal
    add_column :buffs, :max_stacks, :integer
  end
end
