@Thrillhouse.module 'BattledomeApp', (BattledomeApp, App, Backbone, Marionette, $, _) ->

  class BattledomeApp.Router extends Marionette.AppRouter
    appRoutes:
      'battledome' : 'show'

  API =
    show: ->
      new BattledomeApp.Show.Controller

  App.reqres.setHandler 'battledome:show', ->
    App.navigate Routes.battledome_path()
    API.show()

  App.addInitializer ->
    new BattledomeApp.Router
      controller: API
