@Thrillhouse.module 'HomeApp', (HomeApp, App, Backbone, Marionette, $, _) ->

  class HomeApp.Router extends Marionette.AppRouter
    appRoutes:
      'home' : 'show'

  API =
    show: ->
      new HomeApp.Show.Controller

  App.reqres.setHandler "go:home", ->
    App.navigate Routes.home_path()
    API.show()

  App.addInitializer ->
    new HomeApp.Router
      controller: API
