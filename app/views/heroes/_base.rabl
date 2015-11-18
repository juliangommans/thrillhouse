attributes :id, :name, :hero_class

child :hero_items do
  extends "hero_items/base"
end

child :hero_inventory do
  extends "hero_inventory/base"
end
