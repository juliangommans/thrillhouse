######################################
require_relative "./seeding_data/characters_for_seeding"
require_relative "./seeding_data/movelist_for_seeding"

######################################

# moves_array = [MoveSeeds.fire_moves_1, MoveSeeds.air_moves_1, MoveSeeds.water_moves_1]

# moves_array.each do |moves|
#   moves.each do |move|
#     puts move
#     x = Move.create(name: move[:name], category: move[:type], realm: move[:realm], element: move[:element], power: move[:power], cost: move[:cost], cooldown: move[:cooldown], rank: move[:rank], tier: move[:tier])
#     x.save!
#   end
# end

######################################

# character_array = [Characters.bear,Characters.eagle,Characters.tiger]

# character_array.each do |char|
#   puts char
#   z = Character.create(name: char[:name], breed: char[:breed], specialisation: char[:spec], action_points: 4, critical_strike_chance: 0, critical_strike_power: 1.5, combo_points: 0, health: char[:hp], attack: char[:atk], defense: char[:d], energy: char[:eng],  resilience: char[:res], speed: char[:spd])
#   z.save!
# end

######################################

# character_array.count.times do |movelist|
#   bob = Move.where(element: Character.find((movelist+1)).specialisation)
#   bob.each do |move|
#   puts bob
#     y = MoveList.create(move_id: move.id, character_id: (movelist+1))
#     y.save!
#   end
# end

######################################
