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
      @listeningForShow fireView
      @layout.fireRegion.show fireView

    waterMoves: (moves) ->
      waterView = @getMovesView moves, "Water"
      @listeningForShow waterView
      @layout.waterRegion.show waterView

    airMoves: (moves) ->
      airView = @getMovesView moves, "Air"
      @listeningForShow airView
      @layout.airRegion.show airView

    listeningForShow: (view) ->
      @listenTo view, "childview:get:move:show", (child, args) ->
        App.request "move:show", args.model

    getMovesView: (moves, element) ->
      model = new Backbone.Model {name: element}
      new List.MoveList
        collection: moves
        model: model

    getLayout: ->
      new List.Layout
