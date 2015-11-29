attributes :id, :heroes_id, :hero_items_id, :spell

node :item_colour do |x|
  x.hero_items.colour
end

node :spell_stat do |x|
  x.hero_items.spell_stat
end

node :change do |x|
  x.hero_items.change
end
