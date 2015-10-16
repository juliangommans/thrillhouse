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

    actionMove: ->
      for move in @movesArray
        @sortMoveType(move.move, move.owner)

    sortMoveType: (move, owner) ->
      switch move.category
        when "damage"
          @resolveMove(move, "them", owner)
        when "heal"
          @resolveMove(move, "us", owner)
        when "utility"
          console.log "this is a utility move"
        else
          alert "you done fucked up son - i.e. this is not a move =>", move

    resolveMove: (move, target, owner) ->
      confirmedTarget = @getOwnersTarget(owner, target)
      modifier = @getModifier(move)
      if move.category is "damage"
        total = @damageCalculation(move, modifier, confirmedTarget)
        message = "<p>#{@oppositeTarget(confirmedTarget)}s #{move.name} deals <b>#{total}</b> damage to #{confirmedTarget}</p>"
      else if move.category is "heal"
        total = @healCalculation(move, modifier, confirmedTarget)
        message = "<p>#{confirmedTarget}s #{move.name} healed them for <b>#{total}</b> health</p>"
      else
        console.log "yeah mate, nah"
      # message = @buffMessage(move, message, owner)
      @outcome.push {
        move:
          move: move
          cooldown: move.cooldown
          buffs: move.buffs
          owner: owner
          target: confirmedTarget
        healthChange: total
        target: confirmedTarget
        owner: owner
        message: message
      }

    buffMessage: (move, message, owner) ->
      console.log "buff message move", move
      if move.buffs.length > 0
        message += "<p>#{move.stat_target} has had their #{move.stat}</p>"
      else
        message

    getRealm: (move) ->
      if move.realm is "corporeal"
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
      newTarget = @getTargetObject(target)
      damage = move.power * newTarget.opposite.get('base_stats')[realm.damage]
      total = damage / newTarget.target.get('base_stats')[realm.resistence]
      total = total * modifier / 2
      Math.floor(total)

    healCalculation: (move, modifier, target) ->
      target = @getTargetObject(target).target
      realm = @getRealm(move)
      heal = move.power * target.get('base_stats')[realm.damage]
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
      console.log "moveObject =>", moveObject
      if moveObject.moves.length > 0
        @movesArray.push({
          move: moveObject.moves.shift()
          owner: moveObject.owner
          })

    buildMoveObject: (owner) ->
      if owner is "opponent"
        array = @opponentMoveArray
      else if owner is "player"
        array = @moves
      else
        console.log "we have no owner"
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


