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
          @resolveDamage(move)
        when "heal"
          @resolveHeal(move)
        when "utility"
          console.log "this is a utility move"
        else
          alert "you done fucked up son"

    resolveDamage: (move) ->
      damage = move.power * @player.get('base_stats').attack
      totalDamage = @damageCalculation(damage)
      message = "<p>Your #{move.name} dealt <b>#{totalDamage}</b> damage to your opponent</p>"
      @outcome.push {
        move:
          move: move
          cooldown: move.cooldown
        healthChange: totalDamage
        target: "opponent"
        message: message
      }

    resolveHeal: (move) ->
      heal = move.power * @player.get('base_stats').energy
      totalHeal = @healCalculation(heal)
      message = "<p>Your #{move.name} healed you for <b>#{totalHeal}</b> health</p>"
      @outcome.push {
        move:
          move: move
          cooldown: move.cooldown
        healthChange: totalHeal
        target: "player"
        message: message
      }

    damageCalculation: (damage) ->
      total = damage / @opponent.get('base_stats').defense
      total / 2
      Math.floor(total)

    healCalculation: (heal) ->
      combinedDef =  @player.get('base_stats').defense +  @player.get('base_stats').resilience
      total = heal / combinedDef
      Math.ceil(total)
