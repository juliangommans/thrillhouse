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
      @player.set location: location

    fetchEnemies: ->
      enemiesJquery = $('.enemy')
      console.log "list", enemiesJquery
      if enemiesJquery.length > 0
        @enemies = new App.Entities.Collection
        @buildEnemies(enemiesJquery)
      else
        console.log "no enemies"

    buildEnemies: (list) ->
      list.each( (index, object) =>
        type = object.classList[0]
        char = App.request "lilrpg:#{type}:enemy"
        char.set id: (index+1)
        char.set location: $(object).parent().attr('id')
        char.set name: "#{char.get('name')}-#{index+1}"
        @enemies.add char
        $(object).data("name",char.get('name'))
        $(object).attr('id',char.get('id'))
        @setCharHealth(char, object)
      )

    setCharHealth: (char, object) ->
      location = @getOffset(object)
      if $("##{char.get('name')}").length
        $("##{char.get('name')}").remove()
      health = "<div id=#{char.get('name')} class='health' style='left:#{location.left-3}px;top:#{location.top-15}px;'>"
      for hp in [1..char.get('maxHealth')]
        health += "<div class='health-bar positive-health'></div>"
      health += "</div>"
      $('body').append(health)

    filterKey: (key) ->
      targetModel = @getTargetModel()
      switch key.action
        when "move"
          @player.move(key,@map)
          @movePlayer()
        when "attack"
          @dealDamage("attack")
          if targetModel.get('alive')
            @player.attack(key,targetModel)
          else
            @cleanup(targetModel)


    movePlayer: ->
      unless @player.get('location') is @player.get('oldLocation')
        playerObj = $(".player").clone()
        $(".player").remove()
        $("##{@player.get('location')}").append(playerObj)

    dealDamage: (action) ->
      damage = @player.damage[action]
      target = @getTargetModel()
      enemyHp = target.get('health')
      enemyHp -= damage
      target.set alive: false if enemyHp < 1
      target.set health: enemyHp

    cleanup: (model) ->
      $("##{model.get('name')}").remove()
      $("##{model.get('id')}").remove()


    getTargetModel: ->
      @enemies.find((enemy) =>
        enemy.get('name') == $(@player.get('target')).data('name'))

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
      @setPlayerLocation()
      @fetchEnemies()

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
