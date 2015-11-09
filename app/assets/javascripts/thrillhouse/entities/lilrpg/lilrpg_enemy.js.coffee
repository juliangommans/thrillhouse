@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Enemy extends App.Entities.LilrpgModel

    defaults:
      health: 3
      maxHealth: 3
      damage: 1
      range: 1
      alive: true
      moveSpeed: 130
      stunned: false
      attackSpeed: 1500
      name: "TestSubject"

    getLoc: (range) ->
      [{
        dir: "left"
        x: -range
        y: 0
        },{
        dir: "down"
        x: 0
        y: -range
        },{
        dir: "up"
        x: 0
        y: range
        },{
        dir: "right"
        x: range
        y: 0
      }]

    pulse: (coords,player) ->
      @player = player
      @coords = coords
      @location = coords[@get('location')]
      @sensor = setInterval(@scanArea,@get('attackSpeed'))

    scanArea: =>
      if @get('alive') and @player.get('alive')
        enemyCoords = @coords[@get('location')]
        for x in [1..@get('range')]
          @checkLoc(@getLoc(x))
        # console.log "coords", enemyCoords
      else
        clearInterval(@sensor)

    checkLoc: (locArray) ->
      for item in locArray
        newLoc =
          x: @location.x + item.x
          y: @location.y + item.y
        @playerChecker(newLoc)

    playerChecker: (newLoc) ->
      id = "#cell-#{newLoc.x}-#{newLoc.y}"
      if $(id).children().length
        object = $($(id).children()[0])
        if object.hasClass('player')
          @attackPlayer()

    attackPlayer: ->
      playerHp = @player.get('health')
      console.log "before", playerHp
      playerHp -= @get('damage')
      @player.set health: playerHp
      if @player.get('health') < 1
        @player.set alive: false

      #fire damage animation
      console.log "after", @player.get('health')


  class LilrpgApp.SimpleMeleeEnemy extends LilrpgApp.Enemy


  class LilrpgApp.SimpleRangedEnemy extends LilrpgApp.Enemy

    initialize: ->
      @set
        health: 2
        maxHealth: 2
        range: 3
        alive: true
        attackSpeed: 3000


  API =
    simpleMeleeEnemy: ->
      new LilrpgApp.SimpleMeleeEnemy
    simpleRangedEnemy: ->
      new LilrpgApp.SimpleRangedEnemy

  App.reqres.setHandler "lilrpg:simple-melee:enemy", ->
    API.simpleMeleeEnemy()

  App.reqres.setHandler "lilrpg:simple-ranged:enemy", ->
    API.simpleRangedEnemy()
