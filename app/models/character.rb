class Character < ActiveRecord::Base
  has_many :passives
  has_many :buffs
  has_and_belongs_to_many :moves
end
