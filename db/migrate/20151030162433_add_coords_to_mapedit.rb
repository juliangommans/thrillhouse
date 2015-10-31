class AddCoordsToMapedit < ActiveRecord::Migration
  def change
    add_column :lil_rpg_map_editors , :coordinates, :text
  end
end
