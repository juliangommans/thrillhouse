@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.Controller extends App.Controllers.Base

    initialize: ->
      @directions = ['up', 'down', 'left','right']
      @walls = ['vertical-wall', 'horizontal-wall']
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
      coordinates = {}
      for row in [1..@mapSize]
        mapRow = "<div id='row-#{row}' class='map-row'>"
        for cell in [1..@mapSize]
          id = "cell-#{row}-#{cell}"
          mapCell = "<div id='#{id}' class='map-cell cell'></div>"
          mapRow += mapCell
          coordinates[id] =
            x: row
            y: cell
        mapRow += "</div>"
        mapObject += mapRow
      @renderMapTemplate(mapObject, coordinates)

    renderMapTemplate: (map, coordinates) ->
      $('#save-map-name').val('')
      @map = App.request "new:lilrpg:map:entity"
      console.log @map
      @map.set coordinates: JSON.stringify(coordinates)
      $('#map-area').empty()
      $('#map-area').append(map)

    buildBoundaries: ->
      boundaries = []
      for loc in [1..@mapSize]
        boundaries.push
          right: @mapSize
          left: loc

      boundaries

    placeObject: (args, domject) ->
      if $(args.currentTarget)[0].children.length
        @changeDirection(args,domject)
      else
        unless $('#map-area .player').length and domject.hasClass('player')
          $(args.currentTarget).append(domject)
        if domject.hasClass('character')
          domject.addClass('up')

    changeDirection: (args, domject) ->
      target = $($(args.currentTarget)[0].children[0])
      if target.hasAnyClass(@directions).bool
        currentDirection = @directions[target.hasAnyClass(@directions).index]
        @switchCharDirection(target, currentDirection)
      else if target.hasAnyClass(@walls).bool
        wall = @walls[target.hasAnyClass(@walls).index]
        @switchWallDirection(target, wall)
      else
        console.log "directional logic failed"

    switchWallDirection: (target, wall) ->
      target.removeClass(wall)
      if wall is @walls[0]
        target.addClass(@walls[1])
      else
        target.addClass(@walls[0])

    switchCharDirection: (target, currentDirection) ->
      target.removeClass(currentDirection)
      switch currentDirection
        when "up"
          target.addClass('right')
        when "right"
          target.addClass('down')
        when "down"
          target.addClass('left')
        when "left"
          target.addClass('up')

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
      console.log "does this have id?", @map
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
      $('#map-area .cell').empty()
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

      @layout.mapRegion.show mapShowView

    mapUiView: ->
      uiView = @getMapUiView()
      @listenTo uiView, "show", ->
        @bob = new Backbone.Marionette.Region
          el: "#map-load-select"
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

        @bob.show loadView

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
