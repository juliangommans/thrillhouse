@Thrillhouse.module 'BattledomeApp.Ai', (Ai, App, Backbone, Marionette, $, _) ->

  class Ai.Controller extends App.Controllers.Base

    initialize: (options) ->
      @opponent = options.opponent
      @total_ap = @opponent.get("totals").action_points
      @ap = @opponent.get("secondary_stats").action_points
      @moves = @opponent.get("moves")
      @selectedMoves = []
      @selectMoves()

    selectMoves: ->
      for item in [1..6]
        @checkMove(_.sample(@moves))

    checkMove: (move) ->
      if move.cost <= @ap
        @selectedMoves.push(move)
        @ap -= move.cost
