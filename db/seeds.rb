######################################
# require_relative "./seeding_data/characters_for_seeding"
# require_relative "./seeding_data/simple_movelist"
# require_relative "./seeding_data/bufflist_for_seeding"
# require_relative "./seeding_data/movelist_for_seeding"
require_relative "./seeding_data/heroes_items_seeding"

######################################

# moves_array = [MoveSeeds.fire_moves_1, MoveSeeds.air_moves_1, MoveSeeds.water_moves_1]

# moves_array.each do |moves|
#   moves.each do |move|
#     puts move
#     x = Move.create(name: move[:name], category: move[:type], critical_damage: move[:critical_damage], realm: move[:realm], element: move[:element], power: move[:power], cost: move[:cost], cooldown: move[:cooldown], stat: move[:stat], stat_target: move[:stat_target], stat_type: move[:stat_type], description: move[:description], rank: move[:rank], tier: move[:tier])
#     x.save!
#   end
# end

# #####################################

# character_array = [Characters.bear,Characters.eagle,Characters.tiger]

# character_array.each do |char|
#   puts char
#   z = Character.create(name: char[:name], breed: char[:breed], specialisation: char[:spec], action_points: 4, critical_strike_chance: 0, critical_strike_power: 1.5, combo_points: 0, health: char[:hp], attack: char[:atk], defense: char[:d], energy: char[:eng],  resilience: char[:res], speed: char[:spd])
#   z.save!
# end

# #####################################

# character_array.count.times do |movelist|
#   bob = Move.where(element: Character.find((movelist+1)).specialisation)
#   bob.each do |move|
#   puts bob
#     y = MoveList.create(move_id: move.id, character_id: (movelist+1))
#     y.save!
#   end
# end

# #####################################

# buffs_array = Buffs.list
# buffs_array.each do |buff|
#   puts buff
#   b = Buff.create(name: buff[:name], buff_type: buff[:buff_type], stat: buff[:stat], value: buff[:value], stacks: buff[:stacks], max_stacks: buff[:max_stacks])
#   b.save!
# end

# #####################################

# buffs = Buff.all
# buffs.each do |buff|
#   moves_with_buffs = Move.where(stat: buff.stat)
#   if moves_with_buffs
#     moves_with_buffs.each do |move|
#       if buff.buff_type == move.stat_type
#         e = Effect.create(move_id: move.id, buff_id: buff.id)
#         e.save!
#         puts e
#       end
#     end
#   end
# end

items_array = [HeroItemList.fragments, HeroItemList.orbs]
items_array.each do |item_type|
  item_type.each do |item|
    h = HeroItems.create(name: item[:name], colour: item[:colour], category: item[:category], description: item[:description])
    h.save!
  end
end

