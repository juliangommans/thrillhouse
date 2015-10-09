@Thrillhouse.module 'BattledomeApp.Combat', (Combat, App, Backbone, Marionette, $, _) ->

  class Combat.Controller extends App.Controllers.Base

    initialize: (options) ->
      {@player, @opponent, @moves} = options
      @outcome = []
      @movesArray = []
      @opponentMoves = App.request 'battledome:ai', options
      @opponentMoveArray = @opponentMoves.selectedMoves
      @compileMoveOrder()
      if @movesArray.length > 0
        @actionMove()
      else
        alert "You have not selected any moves."
      console.log "move array", @movesArray

    actionMove: ->
      for move in @movesArray
        @sortMoveType(move.move, move.owner)

    sortMoveType: (move, owner) ->
      switch move.category
        when "damage"
          @resolveMove(move, @oppositeTarget(owner))
        when "heal"
          @resolveMove(move, owner)
        when "utility"
          console.log "this is a utility move"
        else
          alert "you done fucked up son"

    resolveMove: (move, target) ->
      modifier = @getModifier(move)
      if move.category is "damage"
        total = @damageCalculation(move, modifier)
        message = "<p>#{@oppositeTarget(target)}s #{move.name} deals <b>#{total}</b> damage to #{target}</p>"
      else if move.category is "heal"
        total = @healCalculation(move, modifier)
        message = "<p>#{target}s #{move.name} healed them for <b>#{total}</b> health</p>"
      else
        console.log "yeah mate, nah"
      @outcome.push {
        move:
          move: move
          cooldown: move.cooldown
        healthChange: total
        target: target
        owner: @oppositeTarget(target)
        message: message
      }

    getRealm: (move) ->
      if move.realm is "ethereal"
        return {
          damage: "attack"
          resistence: "defense"
        }
      else
        return {
          damage: "energy"
          resistence: "resilience"
        }

    getModifier: (move) ->
      modifier = 1
      if move.bonus
        modifier += 0.5
      if move.critical
        modifier += move.critical_damage
      return modifier

    damageCalculation: (move, modifier, target) ->
      realm = @getRealm(move)
      target = @getTargetObject(target)
      damage = move.power * target.target.get('base_stats')[realm.damage]
      total = damage / target.opposite.get('base_stats')[realm.resistence]
      total = total * modifier / 2
      Math.floor(total)

    healCalculation: (move, modifier, target) ->
      target = @getTargetObject(target).target
      heal = move.power * target.get('base_stats')[@getRealm(move).damage]
      combinedDef =  target.get('base_stats').defense + target.get('base_stats').resilience
      total = heal / combinedDef
      Math.ceil(total)

    compileMoveOrder: ->
      total = @moves.length + @opponentMoveArray.length
      for x in [1..total]
        @orderMoves()
      @resetSpeed()

    orderMoves: () ->
      if @player.get('base_stats').speed > @opponent.get('base_stats').speed
        if @moves.length < 1
          moveObject = @buildMoveObject("opponent")
        else
          moveObject = @buildMoveObject("player")
      else
        if @opponentMoveArray.length < 1
          moveObject = @buildMoveObject("player")
        else
          moveObject = @buildMoveObject("opponent")

      @enterMoves(moveObject)

    enterMoves: (moveObject) ->
      if moveObject.moves.length > 0
        @movesArray.push({
          move: moveObject.moves.shift()
          owner: moveObject.owner
          })

    buildMoveObject: (owner) ->
      if owner is "opponent"
        array = @opponentMoveArray
      else
        array = @moves

      @adjustSpeed(owner)

      move =
        moves: array
        owner: owner

    adjustSpeed: (owner) ->
      target = @getTargetObject(owner).target
      totalSpeed = target.get('base_stats').speed * 0.8
      target.get('base_stats').speed = totalSpeed

    resetSpeed: ->
      @opponent.get('base_stats').speed = @opponent.get('totals').speed
      @player.get('base_stats').speed = @player.get('totals').speed


