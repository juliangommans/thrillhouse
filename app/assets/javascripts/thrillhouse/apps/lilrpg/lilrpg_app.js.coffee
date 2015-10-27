@Thrillhouse.module 'LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.Router extends Marionette.AppRouter
    appRoutes:
      'lilrpg' : 'show'
      'lilrpg/mapeditor' : "mapeditor"

  API =
    show: ->
      new LilrpgApp.Show.Controller
    mapeditor: ->
      new LilrpgApp.Mapeditor.Controller

  App.reqres.setHandler 'lilrpg:show', ->
    App.navigate Routes.lilrpg_path()
    API.show()

  App.reqres.setHandler 'lilrpg:mapeditor', ->
    App.navigate Routes.edit_lilrpg_path()
    API.show()

  App.addInitializer ->
    new LilrpgApp.Router
      controller: API