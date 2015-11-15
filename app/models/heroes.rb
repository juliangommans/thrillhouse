class Heroes < ActiveRecord::Base
  has_one :hero_inventory
  has_many :items, through: :hero_inventory
  validates :name, uniqueness: true


  def create
    @hero = Heroes.new
    HeroInventory.new(heroes_id: @hero.id)
  end
end
