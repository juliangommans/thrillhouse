attributes :id, :name, :category, :realm, :element, :power, :cost, :cooldown, :critical, :critical_damage, :stat, :stat_target, :rank, :tier

node(:description) do |move|
  move.rails_description
end

child :buffs do
  extends("buff/_base")
end
