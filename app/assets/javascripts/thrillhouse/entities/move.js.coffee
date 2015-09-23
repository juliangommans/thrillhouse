@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Move extends App.Entities.Model
    urlRoot: -> Routes.move_index_path()

  class Entities.MoveCollection extends App.Entities.Collection
    model: Entities.Move
    url: -> Routes.move_index_path()

  API =
    getMoves: ->
      moves = new Entities.MoveCollection
      moves.fetch
        reset: true
      moves
    getMove: (id) ->
      move = new Entities.Move
        id: id
      move.fetch()
      move
    newMove: ->
      new Entities.Move

  App.reqres.setHandler 'move:entities', ->
    API.getMoves()

  App.reqres.setHandler 'move:entity', (id) ->
    API.getMove id

  App.reqres.setHandler 'new:move:entity', ->
    API.newMove()
