module HeroItemList

  def self.fragments
    [{
      name: "Ruby Fragment",
      category: "fragment",
      colour: "ruby",
      description: "You need 10 of these to make 1 ruby, ruby's increase your abilities damage"
    },
    {
      name: "Sapphire Fragment",
      category: "fragment",
      colour: "sapphire",
      description: "You need 10 of these to make 1 sapphire, sapphire's reduces your abilities cooldown"
    },
    {
      name: "Topaz Fragment",
      category: "fragment",
      colour: "topaz",
      description: "You need 10 of these to make 1 topaz, topaz's increase your abilities range"
    }]
  end

  def self.orbs
    [{
      name: "Ruby Orb",
      category: "orb",
      colour: "red",
      description: "A Ruby Orb increases the associated abilities damage by 1"
    },
    {
      name: "Sapphire Orb",
      category: "orb",
      colour: "sapphire",
      description: "A Sapphire Orb decreases the associated abilities cooldown by 20%"
    },
    {
      name: "Topaz Orb",
      category: "orb",
      colour: "topaz",
      description: "A Topaz Orb increases the associated abilities range by 1"
    }]
  end

end
