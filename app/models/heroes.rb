class Heroes < ActiveRecord::Base
  has_one :hero_inventory
  has_many :hero_items, through: :hero_inventory
  validates :name, uniqueness: true


  def create
    @hero = Heroes.new
  end
end
