@Thrillhouse.module 'MoveApp.List', (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @moves = App.request "move:entities"
      App.execute "when:fetched", @moves, =>
        @layout = @getLayout()

        @listenTo @layout, 'show', =>
          @fireMoves @buildElementMoves(@moves, "fire")
          @waterMoves @buildElementMoves(@moves, "water")
          @airMoves @buildElementMoves(@moves, "air")

        @show @layout

    fireMoves: (moves) ->
      fireView = @getMovesView moves, "Fire"
      @layout.fireRegion.show fireView

    waterMoves: (moves) ->
      waterView = @getMovesView moves, "Water"
      @layout.waterRegion.show waterView

    airMoves: (moves) ->
      airView = @getMovesView moves, "Air"
      @layout.airRegion.show airView

    getMovesView: (moves, element) ->
      model = new Backbone.Model {name: element}
      new List.MoveList
        collection: moves
        model: model

    getLayout: ->
      new List.Layout
