class Character < ActiveRecord::Base
  has_many :passives
  has_many :buffs
  has_many :move_lists
  has_many :moves, through: :move_lists
  validates :name, uniqueness: true
end
