@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.Controller extends App.Controllers.Base

    initialize: ->
      console.log "for my sanity"
      @mapSize = 12

      @layout = @getLayout()

      @listenTo @layout, 'show', =>
        @mapHeaderView()
        @mapSidebarView()
      @show @layout

    mapHeaderView: ->
      mapHeaderView = @getMapHeaderView()
      @listenTo mapHeaderView, "map:options", (value) =>
        @mapSize = parseInt(value)

      @listenTo mapHeaderView, "show", ->
        $('#map-editor-modal').modal('show')

      @listenTo mapHeaderView, "hide:modal", ->
        $('.modal-backdrop').remove();

      @layout.mapHeaderRegion.show mapHeaderView

    mapSidebarView: ->
      mapSidebarView = @getSidebarView()

      @layout.mapSidebarRegion.show mapSidebarView

    getLayout: ->
      new Mapeditor.Layout

    getSidebarView: ->
      new Mapeditor.Sidebar

    getMapHeaderView: ->
      new Mapeditor.Header
