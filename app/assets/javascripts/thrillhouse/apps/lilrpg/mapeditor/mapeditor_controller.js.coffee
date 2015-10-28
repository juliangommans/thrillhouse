@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.Controller extends App.Controllers.Base

    initialize: ->
      console.log "for my sanity"
      @mapSize = 12
      @selected = false

      @layout = @getLayout()

      @listenTo @layout, 'show', =>
        @mapHeaderView()
        @buildSideBar("objects")
        @mapShowView()

      @show @layout

    buildMap: ->
      $('#map-area').empty()
      mapObject = ""
      for row in [1..@mapSize]
        mapRow = "<div id='row-#{row}' class='map-row'>"
        for cell in [1..@mapSize]
          mapCell = "<div id='#{row}#{cell}' class='map-cell cell'></div>"
          mapRow += mapCell
        mapRow += "</div>"
        mapObject += mapRow

      @renderMapTemplate(mapObject)

    renderMapTemplate: (map) ->
      $('#map-area').append(map)

    placeObject: (args, classes, domject) ->
      console.log "domject", domject
      if classes is "empty-cell"
        $(args.currentTarget).empty()
        console.log " (if) this is the target", $(args.currentTarget), classes
      else
        $(args.currentTarget).append(domject)

    mapHeaderView: ->
      mapHeaderView = @getMapHeaderView()
      @listenTo mapHeaderView, "map:options", (value) =>
        @mapSize = parseInt(value)

      @listenTo mapHeaderView, "show", ->
        $('#map-editor-modal').modal('show')

      @listenTo mapHeaderView, "hide:modal", ->
        $('.modal-backdrop').remove();
        @buildMap()

      @layout.mapHeaderRegion.show mapHeaderView

    buildSideBar: (type) ->
      collection = App.request "lilrpg:map:#{type}"
      App.execute "when:fetched", collection, =>
        @mapSidebarView(collection.collection)

    mapSidebarView: (collection) ->
      mapSidebarView = @getSidebarView(collection)

      @layout.mapSidebarRegion.show mapSidebarView

    mapShowView: ->
      mapShowView = @getMapShowView()

      @listenTo mapShowView, "place:selected:object", (args, classes, domject) =>
        @placeObject(args, classes, domject)

      @listenTo mapShowView, 'show', @buildMap

      @layout.mapRegion.show mapShowView

    getLayout: ->
      new Mapeditor.Layout

    getMapShowView: ->
      new Mapeditor.Show

    getSidebarView: (collection) ->
      new Mapeditor.Sidebar
        collection: collection

    getMapHeaderView: ->
      new Mapeditor.Header
