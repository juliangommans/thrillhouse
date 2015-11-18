@Thrillhouse.module 'LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.Router extends Marionette.AppRouter
    appRoutes:
      'lilrpg' : 'show'
      'lilrpg/mapedit' : "mapeditor"

  API =
    show: ->
      new LilrpgApp.Show.Controller
    mapeditor: ->
      new LilrpgApp.Mapeditor.Controller
    heroinfo: (options) ->
      new LilrpgApp.Heroinfo.Controller options

  App.reqres.setHandler 'lilrpg:show', ->
    App.navigate Routes.lilrpg_path()
    API.show()

  App.reqres.setHandler 'lilrpg:mapeditor', ->
    App.navigate Routes.lilrpg_mapedit_path()
    API.mapeditor()

  App.reqres.setHandler 'lilrpg:heroinfo', (options) ->
    API.mapeditor options

  App.addInitializer ->
    new LilrpgApp.Router
      controller: API
