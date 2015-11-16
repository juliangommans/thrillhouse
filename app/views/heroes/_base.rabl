attributes :id, :name, :hero_class

child :hero_items do
  extends "hero_items/base"
end
