@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.Controller extends App.Controllers.Base

    initialize: ->


      @layout = @getLayout()

      @listenTo @layout, 'show', =>
        @mapHeaderView()
        @mapSidebarView()
      @show @layout


    renderMapTemplate: (args) ->
      console.log "this is the map template args", args

    mapHeaderView: ->
      mapHeaderView = @getMapHeaderView()
      @listenTo mapHeaderView, "reporting:options", @renderMapTemplate

      @listenTo mapHeaderView, "show", ->
        $('#map-editor-modal').modal('show')

      @listenTo mapHeaderView, "hide:modal", ->
        $('.modal-backdrop').remove();

      @layout.mapHeaderRegion.show mapHeaderView

    mapSidebarView: ->
      mapSidebarView = @getMapHeaderView()

      @layout.mapSidebarRegion.show mapSidebarView

    getLayout: ->
      new Mapeditor.Layout

    getSidebarView: ->
      new Mapeditor.Sidebar

    getMapHeaderView: ->
      new Mapeditor.Header
