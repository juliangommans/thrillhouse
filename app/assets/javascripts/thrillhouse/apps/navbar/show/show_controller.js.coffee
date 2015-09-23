@Thrillhouse.module 'NavbarApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      showView = @getShowView()

      @listenTo showView, 'go:home', ->
        App.request 'go:home'

      @listenTo showView, 'get:character:list', ->
        App.request 'character:list'

      @listenTo showView, "get:move:list", ->
        App.request "move:list"

      @show showView

    getShowView: ->
      new Show.Navbar
