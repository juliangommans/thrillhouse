# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151118235244) do

  create_table "buffs", force: true do |t|
    t.string   "name"
    t.string   "buff_type"
    t.string   "stat"
    t.string   "type"
    t.decimal  "value"
    t.integer  "stacks"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "character_id"
    t.integer  "max_stacks"
  end

  add_index "buffs", ["character_id"], name: "index_buffs_on_character_id"

  create_table "characters", force: true do |t|
    t.string   "name"
    t.string   "breed"
    t.integer  "stats"
    t.integer  "health"
    t.integer  "attack"
    t.integer  "defense"
    t.integer  "energy"
    t.integer  "resilience"
    t.integer  "speed"
    t.integer  "action_points"
    t.integer  "critical_strike_chance"
    t.decimal  "critical_strike_power"
    t.integer  "combo_points"
    t.string   "specialisation"
    t.string   "nature"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_combo_points",           default: 5
    t.integer  "total_critical_strike_points", default: 10
  end

  create_table "effects", force: true do |t|
    t.string   "name"
    t.integer  "buff_id"
    t.integer  "move_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "effects", ["buff_id"], name: "index_effects_on_buff_id"
  add_index "effects", ["move_id"], name: "index_effects_on_move_id"

  create_table "hero_inventories", force: true do |t|
    t.integer  "heroes_id"
    t.integer  "hero_items_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "spell",         default: ""
  end

  add_index "hero_inventories", ["hero_items_id"], name: "index_hero_inventories_on_hero_items_id"
  add_index "hero_inventories", ["heroes_id"], name: "index_hero_inventories_on_heroes_id"

  create_table "hero_items", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
    t.string   "colour"
    t.string   "spell",       default: ""
    t.string   "spell_stat",  default: ""
    t.decimal  "change",      default: 1.0
  end

  create_table "heroes", force: true do |t|
    t.string   "name"
    t.string   "hero_class"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lil_rpg_map_editors", force: true do |t|
    t.string   "name"
    t.integer  "size"
    t.text     "map"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "coordinates"
  end

  create_table "move_lists", force: true do |t|
    t.integer  "move_id"
    t.integer  "character_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "move_lists", ["character_id"], name: "index_move_lists_on_character_id"
  add_index "move_lists", ["move_id"], name: "index_move_lists_on_move_id"

  create_table "moves", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "realm"
    t.string   "element"
    t.integer  "power"
    t.integer  "cost"
    t.integer  "cooldown"
    t.integer  "rank"
    t.integer  "tier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "bonus",           default: false
    t.boolean  "critical",        default: false
    t.decimal  "critical_damage"
    t.string   "stat"
    t.string   "stat_type"
    t.string   "stat_target"
    t.string   "description"
  end

  create_table "passives", force: true do |t|
    t.string   "name"
    t.integer  "character_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "passives", ["character_id"], name: "index_passives_on_character_id"

end
