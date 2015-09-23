class Move < ActiveRecord::Base
  has_many :effects
  has_many :move_lists
  has_many :characters, through: :move_lists
  validates :name, uniqueness: true

  def description
    "#{name} is a #{realm} move #{self.realms} that does #{power} #{self.categorys}. #{name} #{self.cooldowns}"
  end

  def categorys
    if "#{category}" == "heal"
      "healing"
    else
      "damage"
    end
  end

  def realms
    if "#{realm}" == "ethereal"
      "(this is special/magical damage, enhanced by 'Energy' and resisted by 'Resilience')"
    else
      "(this is physical damage, enhanced by 'Attack' and resisted by 'Defense')"
    end
  end

  def cooldowns
    case "#{cooldown}"
      when "0"
        "is instant, in that you can use it as many times as you have the action points to use"
      when "1"
        "has a #{cooldown} round cooldown and can be used each turn"
      else
        "has a #{cooldown} round cooldown"
    end
  end
end
