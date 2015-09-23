@Thrillhouse.module 'MoveApp', (MoveApp, App, Backbone, Marionette, $, _) ->

  class MoveApp.Router extends Marionette.AppRouter
    appRoutes:
      'move' : 'list'

  API =
    list: ->
      new MoveApp.List.Controller

  App.reqres.setHandler 'move:list', ->
    App.navigate Routes.move_index_path()
    API.list()

  App.addInitializer ->
    new MoveApp.Router
      controller: API
