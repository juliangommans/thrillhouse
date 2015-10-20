@Thrillhouse.module 'LilcricApp', (LilcricApp, App, Backbone, Marionette, $, _) ->

  class LilcricApp.Router extends Marionette.AppRouter
    appRoutes:
      'lilcric' : 'show'

  API =
    show: ->
      new LilcricApp.Show.Controller
    score: (options) ->
      new LilcricApp.Score.Controller options
    results: (options) ->
      new LilcricApp.Results.Controller options


  App.reqres.setHandler 'lilcric:show', ->
    API.show()

  App.reqres.setHandler 'lilcric:score', (options) ->
    API.score options

  App.reqres.setHandler 'lilcric:results', (options) ->
    API.results options

  App.addInitializer ->
    new LilcricApp.Router
      controller: API
