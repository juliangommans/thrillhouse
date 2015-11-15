module HeroItemList

  def self.fragments
    [{
      name: "Ruby Fragment",
      description: "You need 10 of these to make 1 ruby, ruby's increase your abilities damage"
    },
    {
      name: "Saphire Fragment",
      description: "You need 10 of these to make 1 saphire, saphire's reduces your abilities cooldown"
    },
    {
      name: "Topaz Fragment",
      description: "You need 10 of these to make 1 topaz, topaz's increase your abilities range"
    }]
  end

  def self.orbs
    [{
      name: "Ruby Orb",
      description: "A Ruby Orb increases the associated abilities damage by 1"
    },
    {
      name: "Saphire Orb",
      description: "A Saphire Orb decreases the associated abilities cooldown by 20%"
    },
    {
      name: "Topaz Orb",
      description: "A Topaz Orb increases the associated abilities range by 1"
    }]
  end

end