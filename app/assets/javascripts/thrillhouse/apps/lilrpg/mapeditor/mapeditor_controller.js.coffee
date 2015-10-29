@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.Controller extends App.Controllers.Base

    initialize: ->
      @mapSize = 8
      @mapName = ""
      @layout = @getLayout()

      @listenTo @layout, 'show', =>
        @mapHeaderView()
        @mapSidebarLayout()
        @mapShowView()
        @mapUiView()
      @show @layout

    buildMap: ->
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
      $('#save-map-name').val('')
      @map = App.request "new:lilrpg:map:entity"
      $('#map-area').empty()
      $('#map-area').append(map)

    placeObject: (args, domject) ->
      unless $(args.currentTarget)[0].children.length
        $(args.currentTarget).append(domject)

    saveMap: (args) ->
      mapfile = $("#map-area").clone()
      @mapName = $("#save-map-name").val()
      @map.set(
        name: @mapName
        map: mapfile[0].innerHTML
      )
      unless @map.get('size')
        @map.set size: @mapSize
        @mapList.add @map
      @saveToServer()

    saveToServer: ->
      @map.save {},
        success: (model) ->
          console.log "success", model
        error: (model) ->
          console.log "error yo", model

    setLoadedMap: (selectedID) ->
      @map = @mapList.find((map) ->
        map.get('id') is selectedID
      )

    loadSelectedMap: ->
      $('#save-map-name').val(@map.get('name'))
      $("#map-area").empty()
      $("#map-area").append(@map.get('map'))

    clearMap: ->
      $('.cell').empty()
      console.log "confirm captain", @map

##### Map Views #####

    buildSideBar: (type) ->
      collection = App.request "lilrpg:map:#{type}"
      App.execute "when:fetched", collection, =>
        @mapSidebarView(collection.collection)

    mapHeaderView: ->
      mapHeaderView = @getMapHeaderView()
      @listenTo mapHeaderView, "map:options", (value) =>
        @mapSize = parseInt(value)
      @listenTo mapHeaderView, "show", ->
        $('#map-editor-size-modal').modal('show')
      @listenTo mapHeaderView, "hide:modal", ->
        $('.modal-backdrop').remove();
        @buildMap()

      @layout.mapHeaderRegion.show mapHeaderView

    mapSidebarView: (collection) ->
      mapSidebarView = @getSidebarView(collection)

      @sidebarLayout.compositeRegion.show mapSidebarView

    mapSidebarLayout: ->
      @sidebarLayout = @getSidebarLayout()
      @listenTo @sidebarLayout, "show", ->
        @buildSideBar("objects")
      @listenTo @sidebarLayout, "get:sidebar:collection", (collection) =>
        @buildSideBar(collection)

      @layout.mapSidebarRegion.show @sidebarLayout

    mapShowView: ->
      mapShowView = @getMapShowView()
      @listenTo mapShowView, "place:selected:object", (args, domject) =>
        @placeObject(args, domject)
      @listenTo mapShowView, 'show', @buildMap

      @layout.mapRegion.show mapShowView

    mapUiView: ->
      uiView = @getMapUiView()
      @listenTo uiView, "show", ->
        @layout.addRegion("mapLoadLayout", "#map-load-select")
        @mapLoadView()
      @listenTo uiView, "save:current:map", @saveMap
      @listenTo uiView, "load:selected:map", @loadSelectedMap
      @listenTo uiView, "clear:current:map", @clearMap

      @layout.mapUiRegion.show uiView

    mapLoadView: ->
      @mapList = App.request "lilrpg:map:entities"
      App.execute "when:fetched", @mapList, =>
        loadView = @getMapLoadView()
        @listenTo loadView, "load:selected:map", (id) =>
          @setLoadedMap(id)

        @layout.mapLoadLayout.show loadView

    getLayout: ->
      new Mapeditor.Layout

    getMapUiView: ->
      new Mapeditor.Ui

    getMapShowView: ->
      new Mapeditor.Show

    getMapLoadView: ->
      new Mapeditor.LoadMaps
        collection: @mapList

    getSidebarLayout: ->
      new Mapeditor.SidebarLayout

    getSidebarView: (collection) ->
      new Mapeditor.Sidebar
        collection: collection

    getMapHeaderView: ->
      new Mapeditor.Header