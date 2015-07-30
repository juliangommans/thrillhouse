class MoveList < ActiveRecord::Base
  has_many :moves
  has_many :characters
end
