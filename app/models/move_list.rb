class MoveList < ActiveRecord::Base
  belongs_to :move
  belongs_to :character
end
