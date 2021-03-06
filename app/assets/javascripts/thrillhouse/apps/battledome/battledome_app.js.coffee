@Thrillhouse.module 'BattledomeApp', (BattledomeApp, App, Backbone, Marionette, $, _) ->

  class BattledomeApp.Router extends Marionette.AppRouter
    appRoutes:
      'battledome' : 'show'

  API =
    show: ->
      new BattledomeApp.Show.Controller
    combat: (options) ->
      new BattledomeApp.Combat.Controller options
    ai: (options) ->
      new BattledomeApp.Ai.Controller options

  App.reqres.setHandler 'battledome:show', ->
    App.navigate Routes.battledome_path()
    API.show()

  App.reqres.setHandler 'battledome:combat', (options) ->
    API.combat options

  App.reqres.setHandler 'battledome:ai', (options) ->
    API.ai options

  App.addInitializer ->
    new BattledomeApp.Router
      controller: API
