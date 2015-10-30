@Thrillhouse.module 'LilrpgApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @player = App.request "lilrpg:player:entity"
      @controls = App.request "lilrpg:player:controls"

      App.execute "when:fetched", [@controls, @player], =>


        @layout = @getLayout()
        @listenTo @layout, 'show', =>
          @showView()
          @dialogView()

        @show @layout

    setPlayerLocation: ->
      location = parseInt($(".player").parent().attr('id'))
      console.log "location", $(".player").parent().attr('id')
      @player.set location: location

    filterKey: (key) ->
      if key.action is "move"
        @player.move(key)
        @movePlayer()

    movePlayer: ->
      newLocation = $("##{@player.get('location')}")
    # check validity of newLocation
      if @outOfBounds(newLocation)
        @setPlayerLocation()
      else
        playerObj = $(".player").clone()
        $(".player").parent().empty()
        newLocation.append(playerObj)

    outOfBounds: (newLocation) ->


    setBoundaries: ->


    sortPlayerAction: ->
      event.preventDefault()
      pressedKey = @controls.get("#{event.keyCode}")
      @setPlayerLocation()
      if pressedKey
        @filterKey(pressedKey)

      console.log "this is your pressed key", @controls.get("#{event.keyCode}")

    setLoadedMap: (selectedID) ->
      console.log "setting the loaded map"
      @map = @mapList.find((map) ->
        map.get('id') is selectedID
      )
      @setBoundaries()

    loadSelectedMap: ->
      console.log "this be the map", @map
      $("#map-area").empty()
      $("#map-area").append(@map.get('map'))
      @setPlayerLocation()

#### Views ####

    showView: ->
      showView = @getShowView()
      @listenTo showView, "player:action", @sortPlayerAction

      @layout.showRegion.show showView

    dialogView: ->
      dialogView = @getDialogView()
      @listenTo dialogView, "show", ->
        @layout.addRegion("mapLoadLayout", "#map-load-select")
        @mapLoadView()
      @listenTo dialogView, "load:selected:map", @loadSelectedMap
      @layout.dialogRegion.show dialogView

    mapLoadView: ->
      @mapList = App.request "lilrpg:map:entities"
      App.execute "when:fetched", @mapList, =>
        loadView = @getMapLoadView()
        @listenTo loadView, "show", ->
          $('#load-map-modal-bloop').modal('show')
        @listenTo loadView, "load:selected:map", (id) =>
          console.log "loading a map"
          @setLoadedMap(id)

        @layout.mapLoadLayout.show loadView

    getLayout: ->
      new Show.Layout

    getDialogView: ->
      new Show.Dialog

    getMapLoadView: ->
      new Show.LoadMaps
        collection: @mapList

    getShowView: ->
      new Show.Show
