class UpdatingTables < ActiveRecord::Migration
  def change
    add_reference :buffs, :character, index: true
  end
end
