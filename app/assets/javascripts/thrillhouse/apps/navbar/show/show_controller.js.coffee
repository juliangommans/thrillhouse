@Thrillhouse.module 'NavbarApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      showView = @getShowView()

      @listenTo showView, 'go:home', ->
        App.request 'go:home'

      @listenTo showView, "get:character:list", ->
        App.request "character:list"

      @listenTo showView, "get:battle:dome", ->
        App.request "battledome:show"

      @listenTo showView, "get:move:list", ->
        App.request "move:list"

      @listenTo showView, "get:lil:cric", ->
        App.request "lilcric:show"

      @listenTo showView, "get:lil:rpg", ->
        App.request "lilrpg:show"

      @listenTo showView, "get:lil:rpg:map", ->
        App.request "lilrpg:mapeditor"

      @show showView

    getShowView: ->
      new Show.Navbar
