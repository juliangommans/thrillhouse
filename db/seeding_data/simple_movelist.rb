module MoveSeeds

  def self.air_moves_1
    [{ name: "Electric touch",
      type: "damage",
      realm: "corporeal",
      element: "air",
      power: 15,
      cost: 1,
      stat: "",
      stat_target: "",
      cooldown: 1,
      cooldown_total: 1,
      critical: false,
      critical_damage: 0.5,
      description: "",
      rank: 1,
      tier: 1
    },
    { name: "Wind blast",
      type: "damage",
      realm: "ethereal",
      element: "air",
      power: 25,
      cost: 3,
      stat: "",
      stat_target: "",
      cooldown: 1,
      cooldown_total: 1,
      critical: false,
      critical_damage: 0.5,
      description: "",
      rank: 1,
      tier: 1
    },
     { name: "Static shock",
      type: "damage",
      realm: "ethereal",
      element: "air",
      power: 15,
      cost: 1,
      stat: "",
      stat_target: "",
      cooldown: 1,
      cooldown_total: 1,
      critical: false,
      critical_damage: 1.5,
      description: "Static shock's critical strike deals 150% extra damage.",
      rank: 1,
      tier: 1
    },
    { name: "Thunder rush",
      type: "damage",
      realm: "corporeal",
      element: "air",
      power: 10,
      cost: 2,
      stat: "speed",
      stat_target: "player",
      cooldown: 1,
      cooldown_total: 1,
      critical: false,
      critical_damage: 0.5,
      description: "Increases their speed by 20%",
      rank: 1,
      tier: 1
    },
    { name: "Soothing Breeze",
      type: "heal",
      realm: "ethereal",
      element: "air",
      power: 35,
      cost: 2,
      stat: "resilience",
      stat_target: "player",
      cooldown: 2,
      cooldown_total: 2,
      critical: false,
      critical_damage: 0.5,
      description: "Increases their resilience by 20%",
      rank: 1,
      tier: 1
    },
    { name: "Mist",
      type: "heal",
      realm: "ethereal",
      element: "air",
      power: 20,
      cost: 1,
      stat: "",
      stat_target: "",
      cooldown: 1,
      cooldown_total: 1,
      critical: false,
      critical_damage: 0.5,
      description: "",
      rank: 1,
      tier: 1
    },
    { name: "Thunder storm",
      type: "damage",
      realm: "ethereal",
      element: "air",
      power: 50,
      cost: 4,
      stat: "",
      stat_target: "",
      cooldown: 4,
      cooldown_total: 4,
      critical: false,
      critical_damage: 0.5,
      description: "",
      rank: 1,
      tier: 1
    },
    { name: "Sand storm",
      type: "damage",
      realm: "corporeal",
      element: "air",
      power: 40,
      cost: 4,
      stat: "defense",
      stat_target: "opponent",
      cooldown: 3,
      cooldown_total: 3,
      critical: false,
      critical_damage: 0.5,
      description: "Lowers targets defense by 20%",
      rank: 1,
      tier: 1
    }]
  end
  def self.water_moves_1
    [{ name: "Splash",
      type: "heal",
      realm: "ethereal",
      element: "water",
      power: 25.0,
      cost: 2,
      stat: "defense",
      stat_target: "player",
      cooldown: 2,
      cooldown_total: 2,
      critical: false,
      critical_damage: 0.5,
      description: "Increases their defense by 20%",
      rank: 1,
      tier: 1
    },
    { name: "Douse",
      type: "heal",
      realm: "ethereal",
      element: "water",
      power: 20,
      cost: 2,
      stat: "",
      stat_target: "",
      cooldown: 0,
      cooldown_total: 0,
      critical: false,
      critical_damage: 0.5,
      description: "",
      rank: 1,
      tier: 1
    },
    { name: "Squirt",
      type: "damage",
      realm: "ethereal",
      element: "water",
      power: 10.0,
      cost: 2,
      stat: "",
      stat_target: "",
      cooldown: 1,
      cooldown_total: 1,
      critical: false,
      critical_damage: 2,
      description: "Static shock's critical strike deals 200% extra damage.",
      rank: 1,
      tier: 1
    },
    { name: "Ice slash",
      type: "damage",
      realm: "corporeal",
      element: "water",
      power: 35.0,
      cost: 1,
      stat: "",
      stat_target: "",
      cooldown: 3,
      cooldown_total: 3,
      critical: false,
      critical_damage: 0.5,
      description: "",
      rank: 1,
      tier: 1
    },
    { name: "Chill blaines",
      type: "damage",
      realm: "ethereal",
      element: "water",
      power: 15,
      cost: 2,
      stat: "speed",
      stat_target: "opponent",
      cooldown: 1,
      cooldown_total: 1,
      critical: false,
      critical_damage: 0.5,
      description: "Lowers targets speed by 20%",
      rank: 1,
      tier: 1
    },
    { name: "Icy shard",
      type: "damage",
      realm: "corporeal",
      element: "water",
      power: 20,
      cost: 1,
      stat: "",
      stat_target: "",
      cooldown: 1,
      cooldown_total: 1,
      critical: false,
      critical_damage: 0.0,
      description: "Has no critical damage bonus.",
      rank: 1,
      tier: 1
    },
    { name: "Snow storm",
      type: "damage",
      realm: "ethereal",
      element: "water",
      power: 45.0,
      cost: 4,
      stat: "defense",
      stat_target: "opponent",
      cooldown: 3,
      cooldown_total: 3,
      critical: false,
      critical_damage: 0.5,
      description: "Lowers targets defense by 20%",
      rank: 1,
      tier: 1
    }]
  end
  def self.fire_moves_1
    [{ name: "Singe",
      type: "damage",
      realm: "ethereal",
      element: "fire",
      power: 15.0,
      cost: 2,
      stat: "resilience",
      stat_target: "opponent",
      cooldown: 1,
      cooldown_total: 1,
      rank: 1,
      description: "Lowers targets resilience by 20%",
      critical: false,
      critical_damage: 0.5,
      tier: 1
    },
    { name: "Warmth",
      type: "heal",
      realm: "ethereal",
      element: "fire",
      power: 7.0,
      cost: 1,
      stat: "",
      stat_target: "",
      cooldown: 0,
      cooldown_total: 0,
      rank: 1,
      description: "",
      critical: false,
      critical_damage: 0.5,
      tier: 1
    },
    { name: "Firey shell",
      type: "heal",
      realm: "corporeal",
      element: "fire",
      power: 30,
      cost: 3,
      stat: "defense",
      stat_target: "player",
      cooldown: 2,
      cooldown_total: 2,
      rank: 1,
      description: "Increases their defense by 20%",
      critical: false,
      critical_damage: 0.5,
      tier: 1
    },
    { name: "Molten swipe",
      type: "damage",
      realm: "corporeal",
      element: "fire",
      power: 15.0,
      cost: 1,
      stat: "",
      stat_target: "",
      cooldown: 1,
      cooldown_total: 1,
      rank: 1,
      description: "",
      critical: false,
      critical_damage: 0.5,
      tier: 1
    },
    { name: "Pyro slap",
      type: "damage",
      realm: "corporeal",
      element: "fire",
      power: 25.0,
      cost: 3,
      stat: "",
      stat_target: "",
      cooldown: 1,
      cooldown_total: 1,
      rank: 1,
      description: "",
      critical: false,
      critical_damage: 0.5,
      tier: 1
    },
    { name: "Molten avalanche",
      type: "damage",
      realm: "corporeal",
      element: "fire",
      power: 55.0,
      cost: 4,
      stat: "",
      stat_target: "",
      cooldown: 4,
      cooldown_total: 4,
      rank: 1,
      description: "",
      critical: false,
      critical_damage: 0.5,
      tier: 1
    },
    { name: "Lava Jet",
      type: "damage",
      realm: "ethereal",
      element: "fire",
      power: 40,
      cost: 2,
      stat: "attack",
      stat_target: "opponent",
      cooldown: 3,
      cooldown_total: 3,
      rank: 1,
      description: "Lowers targets attack by 20%",
      critical: false,
      critical_damage: 0.5,
      tier: 1
    }]
  end
end
