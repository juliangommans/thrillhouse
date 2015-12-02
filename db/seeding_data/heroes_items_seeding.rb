module HeroItemList

  def self.fragments
    [{
      name: "Ruby Fragment",
      category: "fragment",
      colour: "ruby",
      description: "You need 10 of these to make 1 ruby orb, these orbs increase your abilities damage"
    },
    {
      name: "Sapphire Fragment",
      category: "fragment",
      colour: "sapphire",
      description: "You need 10 of these to make 1 sapphire orb, these orbs reduces your abilities cooldown"
    },
    {
      name: "Topaz Fragment",
      category: "fragment",
      colour: "topaz",
      description: "You need 10 of these to make 1 topaz orb, these orbs increase your abilities range"
    }]
  end

  def self.orbs
    [{
      name: "Ruby Orb",
      category: "orb",
      colour: "ruby",
      spell_stat: "damage",
      change: 1,
      description: "A Ruby Orb increases the associated abilities damage by 1"
    },
    {
      name: "Sapphire Orb",
      category: "orb",
      colour: "sapphire",
      spell_stat: "cooldownMod",
      change: -0.15,
      description: "A Sapphire Orb decreases the associated abilities cooldown by 20%"
    },
    {
      name: "Topaz Orb",
      category: "orb",
      colour: "topaz",
      spell_stat: "range",
      change: 1,
      description: "A Topaz Orb increases the associated abilities range by 1"
    }]
  end

  def self.super_orbs
    [{
      name: "Amythest Orb",
      category: "orb",
      colour: "amythest",
      spell_stat: "aoe",
      change: 1,
      description: "An Amythest Orb adds an area of effect bonus to your spell"
    },
    {
      name: "Emerald Orb",
      category: "orb",
      colour: "emerald",
      spell_stat: "pierce",
      change: 1,
      description: "An Emerald Orb causes your spell to pierce through enemies"
    },
    {
      name: "Fire Opal Orb",
      category: "orb",
      colour: "fireopal",
      spell_stat: "stun",
      change: 1,
      description: "A Fire Opal Orb causes your spell to stun enemies"
    },
    {
      name: "Obsidian Orb",
      category: "orb",
      colour: "obsidian",
      spell_stat: "multistrike",
      change: 1,
      description: "An Obsidian Orb fires a successive shot of the same spell"
    }
  ]
  end

end
