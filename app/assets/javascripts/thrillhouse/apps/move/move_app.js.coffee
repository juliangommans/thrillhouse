@Thrillhouse.module 'MoveApp', (MoveApp, App, Backbone, Marionette, $, _) ->

  class MoveApp.Router extends Marionette.AppRouter
    appRoutes:
      'move' : 'list'
      'move/:id' : 'show'

  API =
    list: ->
      new MoveApp.List.Controller
    show: (id, move) ->
      new MoveApp.Show.Controller
        id: id
        move: move

  App.reqres.setHandler 'move:list', ->
    App.navigate Routes.move_index_path()
    API.list()

  App.reqres.setHandler 'move:show', (move) ->
    App.navigate Routes.move_path move.id
    API.list move.id, move

  App.addInitializer ->
    new MoveApp.Router
      controller: API
