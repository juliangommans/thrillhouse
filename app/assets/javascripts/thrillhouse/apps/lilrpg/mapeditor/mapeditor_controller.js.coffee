@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.Controller extends App.Controllers.Base

    initialize: ->



      @layout = @getLayout()
      @listenTo @layout, 'show', =>
        @mapSize()
      @show @layout

    mapSize: ->
      $('#map-editor-modal').modal('show')
      size = modalSize
      @mapeditorView()


    getLayout: ->
      new Mapeditor.Layout

    mapeditorView: ->
      mapeditorView = @getMapeditorView()
      @layout.mapeditorRegion.show mapeditorView

    getMapeditorView: ->
      new Mapeditor.Lilrpg