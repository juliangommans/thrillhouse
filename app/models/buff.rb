class Buff < ActiveRecord::Base
  has_many :effects
  has_many :moves, through: :effects
end
