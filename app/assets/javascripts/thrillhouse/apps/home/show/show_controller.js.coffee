@Thrillhouse.module 'HomeApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayout()
      @listenTo @layout, "show", =>
        @showView()
        @panelView()

      @show @layout

    showView: ->
      showView = @getShowView()

      @listenTo showView, "get:character:list", ->
        App.request "character:list"

      @listenTo showView, "get:battle:dome", ->
        App.request "battledome:show"

      @listenTo showView, "get:move:list", ->
        App.request "move:list"

      @listenTo showView, "get:lil:cric", ->
        App.request "lilcric:show"

      @layout.listRegion.show showView

    panelView: ->
      panelView = @getPanelView()
      @layout.panelRegion.show panelView

    getPanelView: ->
      new Show.Panel

    getShowView: ->
      new Show.Home

    getLayout: ->
      new Show.Layout
