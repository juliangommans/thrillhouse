@Thrillhouse.module 'LilrpgApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    onBeforeDestroy: ->
      $('.health').remove()

    initialize: ->
      @controls = App.request "lilrpg:player:controls"

      App.execute "when:fetched", [@controls, @player], =>
        @layout = @getLayout()
        @facingData =
          directions: ['up','right','down','left']
          axis: [-1,1,1,-1]
        @listenTo @layout, 'show', =>
          @showView()
          @dialogView()
          @playerHealthView()
          @inventoryView()

        @show @layout

    setPlayerLocation: ->
      location = $(".player").parent().attr('id')
      @player.set location: location
      @setModelFacingAttributes('.player', @player)

    setModelFacingAttributes: (target, model) ->
      if $(target).hasAnyClass(@facingData.directions).bool
        direction = @facingData.directions[$(target).hasAnyClass(@facingData.directions).index]
        axis = @facingData.axis[$(target).hasAnyClass(@facingData.directions).index]
        model.set facing:
          oldDirection: direction
          direction: direction
          axis: axis

    fetchEnemies: ->
      enemiesJquery = $('.enemy')
      if enemiesJquery.length > 0
        @enemies = new App.Entities.Collection
        @buildEnemies(enemiesJquery)
        @player.set enemies: @enemies
        console.log "enemies list", @enemies
      else
        console.log "no enemies"

    buildEnemies: (list) ->
      list.each( (index, object) =>
        char = @buildEnemyModel(index,object)
        $(object).data("name",char.get('name'))
        $(object).attr('id',char.get('id'))
        @setCharHealth(char, object)
        @runAi(char)
      )

    buildEnemyModel:(index,object) ->
        char = App.request "lilrpg:#{object.classList[0]}:enemy"
        char.set id: (index+1)
        char.set location: $(object).parent().attr('id')
        char.set name: "#{char.get('name')}-#{index+1}"
        @setModelFacingAttributes(object, char)
        @enemies.add char
        char

    runAi: (model) ->
      # model.pulse(@map.get('coordinates'),@player)
      model.engageAi(@map.get('coordinates'),@player)

#### needs a way to cleanup on page change - possibles:
# tie it straight to the enemy dom-element
# append it to "main view", needs offset and some math
    setCharHealth: (char, object) ->
      # location = @getOffset(object)
      total = char.get('maxHealth')
      if $("##{char.get('name')}").length
        $("##{char.get('name')}").remove()
      health = "<div id=#{char.get('name')} class='health' style='width:#{total*4+2};'>" #left:#{location.left-3}px;top:#{location.top-15}px;'>"
      for hp in [1..total]
        health += "<div class='health-bar positive-health'></div>"
      health += "</div>"
      $("##{char.get('id')}").append(health)
      # $('body').append(health)

    filterKey: (key) ->
      switch key.action
        when "move"
          unless @player.get('moveCd') or @player.get('actionCd')
            @player.move(key)
        when "attack"
          unless @player.get('actionCd')
            @player.attack(key)
        when "spell"
          unless @player.get('actionCd')
            @player.spell(key)

    getTargetModel: ->
      @enemies.find((enemy) =>
        if @player.get('target')?
          console.log enemy.get('name'), @player.get('target')
          enemy.id == parseInt($(@player.get('target')).attr('id')))

    sortPlayerAction: ->
      event.preventDefault()
      pressedKey = @controls.get("#{event.keyCode}")
      @setPlayerLocation()
      if pressedKey
        @filterKey(pressedKey)

    setLoadedMap: (selectedID) ->
      @map = @loadMapList.find((map) ->
        map.get('id') is selectedID
      )

    loadSelectedMap: ->
      $("#map-area").empty()
      $("#map-area").append(@map.get('map'))
      @afterMapLoadTasks()

    afterMapLoadTasks: ->
      @getPlayer()
      @setupPlayerHealthBars()
      @fetchEnemies()
      App.execute "when:fetched", @player, =>
        @loadSpellsView()

    getPlayer: ->
      @player = App.request "lilrpg:player:entity",
        map: @map
      @setPlayerLocation()

    setupPlayerHealthBars: ->
      hp = @player.get('maxHealth')
      healthObj = "<div class='health-bar positive-health'></div>"
      for i in [1..hp]
        $('#player-health-bars').append(healthObj)

#### Views ####

    showView: ->
      showView = @getShowView()
      @listenTo showView, "player:action", @sortPlayerAction

      @layout.lilrpgPlayRegion.show showView

    playerHealthView: ->
      healthView = @getPlayerHealthView()

      @layout.healthRegion.show healthView

    inventoryView: ->
      invView = @getInventoryView()
      @listenTo invView, "show", ->
        @spellRegion = new Backbone.Marionette.Region
          el: "#spell-display"

      @layout.invRegion.show invView

    loadSpellsView: ->
      collection = @player.get('spellCollection')
      spellsView = @getSpellsView(collection)

      @spellRegion.show spellsView

    dialogView: ->
      dialogView = @getDialogView()
      @listenTo dialogView, "show", ->
        @dialogMaps = new Backbone.Marionette.Region
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

        @dialogMaps.show loadView

    getLayout: ->
      new Show.Layout

    getDialogView: ->
      new Show.Dialog

    getMapLoadView: ->
      new Show.LoadMaps
        collection: @loadMapList

    getPlayerHealthView: ->
      new Show.PlayerHealth

    getInventoryView: ->
      new Show.Inventory

    getSpellsView: (collection) ->
      new Show.Spells
        collection: collection

    getShowView: ->
      new Show.Show
