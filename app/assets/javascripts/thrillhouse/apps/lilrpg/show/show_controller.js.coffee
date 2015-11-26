@Thrillhouse.module 'LilrpgApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    onBeforeDestroy: ->
      $('.health').remove()

    initialize: ->
      @serverItems = []
      @spellsWithItems = []
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
      model.engageAi(@map.get('coordinates'),@player)

    setCharHealth: (char, object) ->
      total = char.get('maxHealth')
      if $("##{char.get('name')}").length
        $("##{char.get('name')}").remove()
      health = "<div id=#{char.get('name')} class='health'>" #left:#{location.left-3}px;top:#{location.top-15}px;'>"
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
      @checkForLoot()

    checkForLoot: ->
      loc = $("##{@player.get('location')}")
      if $(loc.children()[0])?
        item = $(loc.children()[0])
        if $(loc.children()[0]).hasClass('loot')
          item.remove()
          @chestLoot()

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
      if selectedID?
        @map = @loadMapList.find((map) ->
          map.get('id') is selectedID
        )
      else
        @map = undefined

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
        @hero.buildInventory()
        @fetchPlayer()
        @afterHeroFetch()

    fetchPlayer: ->
      @player = App.request "lilrpg:player:entity",
        map: @map
        hero: @hero
        inventory: @hero.get('inventory')

        hero_items: @hero.get('hero_items')

    afterHeroFetch: ->
      App.execute "when:fetched", @player, =>
        @loadSpellsView()
        @loadInventoryDisplay()

        @setPlayerLocation()
        @updateDisplay()
        @setupPlayerHealthBars()
        @fetchEnemies()

    updateDisplay: ->
      @spellsView.render()
      for item in @hero.get('inventory')
        @checkForSocket(item)

    loadEntities: ->
      @hero or= App.request "heroes:entity", 1
      @controls = App.request "lilrpg:player:controls"
      @items or= App.request "hero:items:entities"

    setupPlayerHealthBars: ->
      hp = @player.get('maxHealth')
      healthObj = "<div class='player-health-bar positive-health'></div>"
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
      @item = App.request "hero:items:entities"
      App.execute "when:fetched", [@hero, @item], =>
        $('#hero-modal').modal('show')
        @hero.buildInventory()
        @showCharacterItems()

    showCharacterItems:  ->
      @spellsWithItems = []
      @clearHeroCss()
      html = "<div class='character-sheet'>"
      for item in @hero.get('inventory')
        html += "<div data-id='#{item.id}' class='inv-box unchecked-loot' data-toggle='popover' data-placement='bottom' data-content='#{item.description}'>"
        html += "<div class='inv-item #{item.className}'></div><div id='#{item.colour}-#{item.category}' class='inv-item'>#{item.total}</div></div>"
        @checkForSocket(item)
      html += "</div>"
      $('#inventory-items').append(html)
      @cleanupInventory()

    cleanupInventory: ->
      if @spellsWithItems?
        for object in @spellsWithItems
          $("##{object.item.colour}-#{object.item.category}").text("#{object.item.total - object.array.length}")

    checkForSocket: (item) ->
      inventory = @hero.get('hero_inventories')
      inv_items = inventory.filter((x) ->
        x.hero_items_id is item.id)
      itemArray = inv_items.filter((x) ->
        return x if x.spell.length > 0?)
      if itemArray.length >= 1
        @spellsWithItems.push(
          item: item
          array: itemArray
          )
        @socketSpell(itemArray)

    socketSpell: (array) ->
      inventory = @hero.get('inventory')
      for inv_item in array
        item = inventory.find((item) ->
          inv_item.hero_items_id is item.id)
        check = false
        for socket in [1..3]
          object = $("##{inv_item.spell}-slot-#{socket}")
          unless object.hasClass('socketed') or check
            object.addClass("socketed #{item.colour}")
            check = true

    removeSpellItem: (jspell) ->
      items = @hero.get('hero_inventories')
      item = _.find(items, (i) =>
        if i.item_colour is jspell[0].classList[3] or i.item_colour is jspell[0].classList[2]
          if i.spell.length > 0
            x = _.find(@serverItems, (s) =>
              s.item.id is i.id)
            unless x?
              return i
        )
      inventory_item = App.request "hero:inventory:entity", item.id
      App.execute "when:fetched", inventory_item, =>
        inventory_item.set spell: ""
        @serverItems.push(
          item: inventory_item
          action: "save"
        )
        jspell.removeClass("#{item.item_colour} socketed")
        $("##{item.item_colour}-orb").text(parseInt($("##{item.item_colour}-orb").text()) + 1)

    itemConversion: (id,spell) ->
      jspell =  $("##{spell}")
      inv = @hero.get('inventory')
      item = _.find(inv, (item) ->
        item.id is id)
      if jspell.attr('id') is 'transmute-box'
        if item.category is "fragment"
          if item?
            @transmuteFragments(item,id)
        else
          if item?
            @transmuteOrbs(item,id,jspell)
      else
        if jspell.hasClass("socketed")
          @removeSpellItem(jspell)
        else unless item.category is "fragment"
          if item?
            @addOrbToSpell(item,inv,id,jspell,spell)

    addOrbToSpell: (item,inv,id,jspell,spell) ->
      if jspell.hasClass("socketed") or parseInt($($(".checked-loot").children()[1]).text()) < 1
        console.log "WRONG HOLE FOOL", jspell
      else
        jspell.addClass("socketed")
        jspell.addClass("#{item.colour}")
        $("##{item.colour}-orb").text(parseInt($("##{item.colour}-orb").text()) - 1)
        @assignSpell(id, spell)

    assignSpell: (id, spell) ->
      inv_item = @findInventoryItem(id)
      getItem = App.request "hero:inventory:entity", inv_item.id
      App.execute "when:fetched", getItem, =>
        selectedSpell = spell.split('-')[0]
        getItem.set spell: selectedSpell
        @serverItems.push(
          item: getItem
          action: "save"
          )

    findInventoryItem: (id) ->
      inventory = @hero.get('hero_inventories')
      inv_item = inventory.find((item) ->
        unless item.assigned
          item.hero_items_id is id and item.spell.length <= 1
        )
      if inv_item?
        inv_item["assigned"] = true
      inv_item

    transmuteFragments: (item,id) ->
      if item.total >= 10
        newTotal = item.total -= 10
        # @destroyFragments(id)
        console.log "item to be transmuted", item
        @createOrb(item.colour)
        @updateInvDisplay(newTotal,item)
      else
        alert "You need at least 10 fragments to transmute an orb"

    transmuteOrbs: (item,id,jspell) ->
      if jspell.hasClass('socketed')
        if jspell.data('id') is id
          alert "you have to select a different type of orb"
        else
          newTotal = item.total - 1
          @updateInvDisplay(newTotal,item)
          items = []
          items.push(@findInventoryItem(jspell.data('id')))
          items.push(@findInventoryItem(id))
          for item in items
            @destroyOrbs(item, jspell)
          @createSuperOrb(items)
      else
        newTotal = item.total - 1
        @updateInvDisplay(newTotal,item)
        jspell.addClass("socketed #{item.colour}")
        jspell.data('id', id)

    destroyOrbs: (invItem, jspell) ->
      jspell.removeClass("socketed #{invItem.item_colour}")
      item = App.request "hero:inventory:entity", invItem.id
      App.execute "when:fetched", item, =>
        @serverItems.push(
          item: item
          action: 'destroy'
          )

    createSuperOrb: (items) ->
      colour1 = items[0].item_colour
      colour2 = items[1].item_colour
      firstColour = @colorMixer()[colour1]
      newColour = firstColour[colour2]
      @createOrb(newColour.colour)
######## no need for id if this works

    colorMixer: ->
      colourObject = {
        ruby: {
          topaz:
            colour: "fireopal"
            id: 21
          sapphire:
            colour: "amythest"
            id: 19
        }
        topaz: {
          ruby:
            colour: "fireopal"
            id: 21
          sapphire:
            colour: "emerald"
            id: 20
        }
        sapphire: {
          topaz:
            colour: "emerald"
            id: 20
          ruby:
            colour: "amythest"
            id: 19
        }
      }


    destroyFragments: (id) ->
      x = App.request "new:hero:inventory:entity"
      App.execute "when:fetched", x, =>
        x.set id: 10
        @serverItems.push(
          item: x
          action: "destroy"
          destroy:
            data:
              heroes_id: @hero.id
              hero_items_id: (id)
            processData: true
          )

    createOrb: (colour) ->
      orb = App.request "new:hero:inventory:entity"
      App.execute "when:fetched", orb, =>
        orb.set(
          hero_inventory:
              heroes_id: @hero.id
              item_colour: colour
              item_category: "orb"
          )
        @serverItems.push(
          item: orb
          action: "save"
          create:
            data:
              heroes_id: @hero.id
              item_colour: colour
              item_category: "orb"
            processData: true
          )

        # orb.set(
        #   hero_inventory:
        #     heroes_id: @hero.id
        #     hero_items_id: id
        #   )
        # @serverItems.push(
        #   item: orb
        #   action: "save"
        #   )

    updateInvDisplay: (newTotal,item) ->
      console.log "item being destroyed??", item
      object = $("##{item.colour}-#{item.category}")
      object.text("#{newTotal}")

    saveHeroChanges: ->
      for object in @serverItems
        console.log "this is each item to save", object
        if object.action is "save"
          @saveItemToServer(object.item)
        else if object.action is "destroy"
          object.item.destroy(object.destroy)
      @hero.fetch()
      @serverItems = []
      @clearHeroCss()

    clearHeroCss: ->
      @mapLoadView()
      $('.spell-slot').removeClass('socketed topaz ruby saphire')
      $('#inventory-items').empty()


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
      @spellsView = @getSpellsView(collection)

      @spellRegion.show @spellsView

    dialogView: ->
      dialogView = @getDialogView()

      @listenTo dialogView, "show", ->
        @dialogMaps = new Backbone.Marionette.Region
          el: "#map-load-list"
        @mapLoadView()

      @listenTo dialogView, "trigger:item:event", (id, spell) =>
        @itemConversion(id,spell)
      @listenTo dialogView, "save:hero:changes", @saveHeroChanges
      @listenTo dialogView, "load:map:modal", @clearHeroCss
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
