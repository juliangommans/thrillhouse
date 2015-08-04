class Move < ActiveRecord::Base
  has_many :effects
  has_many :move_lists
  has_many :characters, through: :move_lists
  validates :name, uniqueness: true
end
