class Effect < ActiveRecord::Base
  belongs_to :move
  belongs_to :buff
end
