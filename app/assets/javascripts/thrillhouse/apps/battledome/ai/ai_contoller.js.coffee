@Thrillhouse.module 'BattledomeApp.Ai', (Ai, App, Backbone, Marionette, $, _) ->

  class Ai.Controller extends App.Controllers.Base

    initialize: (options) ->
      @opponent = options.opponent
      @cooldowns = options.cooldowns.opponent
      @ap = @opponent.get("secondary_stats").action_points
      @moves = @opponent.get("moves")
      @availableMoves = @getAvailableMoves()
      @selectedMoves = []
      @selectMoves()
      console.log "AVAILABLE AI MOVES", @availableMoves

    getAvailableMoves: ->
      array = []
      for move in @moves
        unless @checkCd(move)
          array.push(move)
      array

    checkCd: (move) ->
      _.find(@cooldowns, (cd) ->
        cd.move == move
      )

    selectMoves: ->
      for item in [1..6]
        @checkMove(_.sample(@availableMoves))

    checkMove: (move) ->
      if move.cost <= @ap
        @selectedMoves.push(move)
        @ap -= move.cost
