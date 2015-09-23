attributes :id, :name, :category, :realm, :element, :power, :cost, :cooldown, :rank, :tier

node(:description) do |move|
  move.description
end
