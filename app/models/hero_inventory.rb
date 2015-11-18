class HeroInventory < ActiveRecord::Base
  belongs_to :heroes
  belongs_to :hero_items
end
