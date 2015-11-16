@Thrillhouse.module 'LilrpgApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    onBeforeDestroy: ->
      $('.health').remove()

    initialize: ->
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

      console.log "this is your hero, player", @hero, @player
      console.log "and these are the items", @items
      # @chestLoot()

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

    setCharHealth: (char, object) ->
      total = char.get('maxHealth')
      if $("##{char.get('name')}").length
        $("##{char.get('name')}").remove()
      health = "<div id=#{char.get('name')} class='health' style='width:#{total*4+2};'>" #left:#{location.left-3}px;top:#{location.top-15}px;'>"
      for hp in [1..total]
        health += "<div class='health-bar positive-health'></div>"
      health += "</div>"
      $("##{char.get('id')}").append(health)

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
      console.log "what is this id??", selectedID
      if selectedID?
        @map = @loadMapList.find((map) ->
          map.get('id') is selectedID
        )
      else
        console.log "this is map", @map
        # @loadCharacterSheet()

    loadSelectedMap: ->
      if @map?
        $("#map-area").empty()
        $("#map-area").append(@map.get('map'))
        @afterMapLoadTasks()
      else
        @loadCharacterSheet()


    afterMapLoadTasks: ->
      @loadEntities()
      App.execute "when:fetched", [@hero, @items], =>
        @fetchPlayer()
        @afterHeroFetch()

    fetchPlayer: ->
      @player = App.request "lilrpg:player:entity",
        map: @map
        hero_items: @hero.get('hero_items')

    afterHeroFetch: ->
      App.execute "when:fetched", @player, =>
        @loadSpellsView()
        @loadInventoryDisplay()
        @setPlayerLocation()

        @setupPlayerHealthBars()
        @fetchEnemies()

    loadEntities: ->
      @hero or= App.request "heroes:entity", 1
      @controls = App.request "lilrpg:player:controls"
      @items = App.request "hero:items:entities"

    setupPlayerHealthBars: ->
      hp = @player.get('maxHealth')
      healthObj = "<div class='health-bar positive-health'></div>"
      for i in [1..hp]
        $('#player-health-bars').append(healthObj)

    chestLoot: ->
      fragments = @items.filter((item) ->
        item.get('category') is "fragment")
      @itemMath(fragments)

    itemMath: (fragments) ->
      @loot = []
      itemOptions = @getRandomNum(1,3)
      for i in [1..itemOptions]
        @loot.push(_.sample(fragments))
      console.log "and htis is the loot", @loot
      @buildLootBox()

    buildLootBox: ->
      $("#loot-outcome").empty()
      for item in @loot
        lootbox = "<div class='loot-box unchecked-loot' data-toggle='popover' data-placement='bottom' data-content='#{item.get('name')}'>"
        lootbox += "<div id='#{item.get('id')}' class='#{item.get('colour')} #{item.get('category')}'></div>"
        lootbox += "</div>"
        $("#loot-outcome").append(lootbox)

      $('#loot-modal').modal('show')

    collectCurrentLoot: ->
      @itemcontainer = []
      itemboxes = $('.loot-box')
      if itemboxes.length
        itemboxes.each( (index, object) =>
          item = App.request "new:hero:inventory:entity"
          App.execute "when:fetched", item, =>
            item.set(
              hero_inventory:
                heroes_id: @hero.id
                hero_items_id: parseInt($($(object).children()[0]).attr('id'))
            )
            @saveItemToServer(item)
            @itemcontainer.push(item)
          )

    saveItemToServer: (item) ->
      item.save {},
        success: (model) =>
          console.log "saved item successfully", model
        error: (model) ->
          console.log "item FAIL", model

    loadCharacterSheet: ->
      @hero = App.request "heroes:entity", 1
      App.execute "when:fetched", @hero, =>
        $('#hero-modal').modal('show')
        console.log "@hero", @hero
        @showSpells()
        @showCharacterItems()

    showCharacterItems:  ->
      @hero.buildInventory()
      console.log "hero", @hero
      html = "<div class='character-sheet'>"
      for item in @hero.get('inventory')
        html += "<div class='inv-box' data-toggle='popover' data-placement='bottom' data-content='#{item.description}''>"
        html += "<div id='item-#{item.id}'class='inv-item #{item.className}''></div><div class='inv-item'>#{item.total}</div></div>"
      html += "</div>"
      $('#inventory-items').append(html)

    showSpells: ->
      console.log "nothing to show yet"



        #add some display shit

    saveHeroChanges: ->
      App.request "lilrpg:heroinfo",
        hero: @hero
        changes: @changes



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
        @inventoryRegion = new Backbone.Marionette.Region
          el: "#inventory-display"

      @layout.invRegion.show invView

    loadInventoryDisplay: ->
      invDisplay = @getInventoryDisplay()

      @inventoryRegion.show invDisplay

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
      @listenTo dialogView, "save:hero:changes", @saveHeroChanges
      @listenTo dialogView, "load:map:modal", @mapLoadView
      @listenTo dialogView, "load:selected:map", @loadSelectedMap
      @listenTo dialogView, "collect:current:loot", @collectCurrentLoot

      @layout.dialogRegion.show dialogView

    mapLoadView: ->
      @loadMapList = App.request "lilrpg:map:entities"
      App.execute "when:fetched", @loadMapList, =>
        loadView = @getMapLoadView()
        @listenTo loadView, "show", ->
          $('#load-map-modal').modal('show')
        @listenTo loadView, "select:current:map", (id) =>
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

    getInventoryDisplay: ->
      new Show.InventoryDisplay
        model: @player

    getShowView: ->
      new Show.Show
