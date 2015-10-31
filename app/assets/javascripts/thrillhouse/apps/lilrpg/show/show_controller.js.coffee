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
      location = $(".player").parent().attr('id')
      console.log "location", $(".player").parent().attr('id')
      @player.set location: location

    filterKey: (key) ->
      if key.action is "move"
        @player.move(key,@map)
        @movePlayer()

    movePlayer: ->
      newLocation = $("##{@player.get('location')}")
      illegalMoves = ['wall','character']
      if $(newLocation[0].children[0]).hasAnyClass(illegalMoves)
        console.log "something is in your way", newLocation
        @setPlayerLocation()
      else
        playerObj = $(".player").clone()
        $(".player").remove()
        newLocation.append(playerObj)

    sortPlayerAction: ->
      event.preventDefault()
      pressedKey = @controls.get("#{event.keyCode}")
      @setPlayerLocation()
      if pressedKey
        @filterKey(pressedKey)

    setLoadedMap: (selectedID) ->
      console.log "setting the loaded map"
      @map = @loadMapList.find((map) ->
        map.get('id') is selectedID
      )

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
        @test = new Backbone.Marionette.Region
          el: "#map-load-list"
        @mapLoadView()
      @listenTo dialogView, "load:selected:map", @loadSelectedMap

      @layout.dialogRegion.show dialogView

    mapLoadView: ->
      @loadMapList = App.request "lilrpg:map:entities"
      App.execute "when:fetched", @loadMapList, =>
        loadView = @getMapLoadView()
        @listenTo loadView, "show", ->
          $('#load-map-modal').modal('show')
        @listenTo loadView, "load:selected:map", (id) =>
          @setLoadedMap(id)

        @test.show loadView

    getLayout: ->
      new Show.Layout

    getDialogView: ->
      new Show.Dialog

    getMapLoadView: ->
      new Show.LoadMaps
        collection: @loadMapList

    getShowView: ->
      new Show.Show
