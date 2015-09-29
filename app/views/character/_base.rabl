attributes :id, :name, :breed, :specialisation, :nature

node :base_stats do |r|
  {
  health: r[:health],
  attack: r[:attack],
  defense: r[:defense],
  energy: r[:energy],
  resilience: r[:resilience],
  speed: r[:speed]
  }
end

node :secondary_stats do |r|
  {
  action_points: r[:action_points],
  critical_strike_chance: r[:critical_strike_chance],
  critical_strike_power: r[:critical_strike_power],
  combo_points: r[:combo_points]
  }
end

child :moves do
  extends("move/_base")
end
