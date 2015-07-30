class Move < ActiveRecord::Base
  has_many :effects
  has_and_belongs_to_many :characters
end
