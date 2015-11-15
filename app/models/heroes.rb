class Heroes < ActiveRecord::Base
  has_one :hero_inventory
  has_many :items, through: :hero_nventory

  def create
    @hero = Heroes.new
    HeroInventory.new(heroes_id: @hero.id)
  end
end
