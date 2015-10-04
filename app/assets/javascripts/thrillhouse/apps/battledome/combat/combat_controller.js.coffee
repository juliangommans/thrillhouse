@Thrillhouse.module 'BattledomeApp.Combat', (Combat, App, Backbone, Marionette, $, _) ->

  class Combat.Controller extends App.Controllers.Base

    initialize: (options) ->
      {@player, @opponent, @moves} = options
      @outcome = []
      if @moves.length > 0
        @actionMove()

    actionMove: ->
      for move in @moves
        @sortMoveType(move)

    sortMoveType: (move) ->
      switch move.category
        when "damage"
          @resolveMove(move, "opponent")
        when "heal"
          @resolveMove(move, "player")
        when "utility"
          console.log "this is a utility move"
        else
          alert "you done fucked up son"

    resolveMove: (move, target) ->
      power = move.power * @player.get('base_stats')[@getRealm(move)]
      modifier = @getModifier(move)
      if move.category is "damage"
        total = @damageCalculation(power, modifier)
        message = "<p>Your #{move.name} dealt <b>#{total}</b> damage to your opponent</p>"
      else if move.category is "heal"
        total = @healCalculation(power, modifier)
        message = "<p>Your #{move.name} healed you for <b>#{total}</b> health</p>"
      else
        console.log "yeah mate, nah"
      @outcome.push {
        move:
          move: move
          cooldown: move.cooldown
        healthChange: total
        target: target
        message: message
      }

    getRealm: (move) ->
      if move.realm is "ethereal"
        return "attack"
      else
        return "energy"

    getModifier: (move) ->
      modifier = 1
      if move.bonus
        modifier += 0.5
      if move.critical
        modifier += move.critical_damage
      return modifier

    damageCalculation: (damage, modifier) ->
      total = damage / @opponent.get('base_stats').defense
      total = total * modifier / 2
      Math.floor(total)

    healCalculation: (heal, modifier) ->
      combinedDef =  @player.get('base_stats').defense +  @player.get('base_stats').resilience
      total = heal / combinedDef
      Math.ceil(total)
