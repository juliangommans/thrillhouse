@Thrillhouse.module 'LilcricApp', (LilcricApp, App, Backbone, Marionette, $, _) ->

  class LilcricApp.Router extends Marionette.AppRouter
    appRoutes:
      'lilcric' : 'show'

  API =
    show: ->
      new LilcricApp.Show.Controller

  App.reqres.setHandler 'lilcric:show', ->
    API.show()
