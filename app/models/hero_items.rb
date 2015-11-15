class HeroItems < ActiveRecord::Base
  has_many :heroes, through: :hero_inventory
  has_many :hero_inventory
end
