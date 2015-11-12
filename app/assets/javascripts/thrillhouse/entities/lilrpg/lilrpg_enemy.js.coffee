@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Enemy extends App.Entities.LilrpgModel

    defaults:
      health: 3
      maxHealth: 3
      damage: 1
      range: 1
      alive: true
      moveSpeed: 1000
      stunned: false
      attackSpeed: 1200
      name: "TestSubject"

    engageAi: (coords,player) ->
      @player = player
      @coords = coords
      @location = coords[@get('location')]
      @patrolLoop = setInterval(@patrol, @get('moveSpeed'))

    patrol: =>
      @breakPatrolLoop()
      @removeProxy()
      unless @get('stunned')
        @set oldLocation: @get('location')

        newCell = @checkCurrentDirection(1)
        if @coords[newCell]
          if @checkIllegalMoves(newCell)
            @checkFacingCell(newCell)
          else
            @moveToNewLoc(newCell)
        else
          @faceOtherDirection()

    breakPatrolLoop: ->
      unless $("##{@get('id')}").length
        clearInterval(@patrolLoop)

    moveToNewLoc: (cell) ->
      @set location: cell
      enemyObj = $("##{@get('id')}").clone()
      $("##{@get('id')}").remove()
      $("##{cell}").append(enemyObj)
      nextCell = @checkCurrentDirection(1)
      if @checkIllegalMoves(nextCell)
        @checkFacingCell(nextCell)
      @createProxyChar()

    createProxyChar: ->
      if @get('alive')
        cell = @get('oldLocation')
        delay = @get('moveSpeed')*0.33
        dummy = "<div id='#{@get('id')}' class='#{@get('name')} dummy' ></div>"
        unless $("##{cell}").children().length
          $("##{cell}").append(dummy)
          setInterval(@removeProxy,delay)

    removeProxy: =>
      if $(".#{@get('name')}").length
        $(".#{@get('name')}").remove()

    checkFacingCell: (newCell) ->
      if @playerChecker(@coords[newCell])
        @set target: @player.get('location')
        clearInterval(@patrolLoop)
        @swing = setInterval(@attackPlayer,@get('attackSpeed'))
      else
        @faceOtherDirection()
    # else

    faceOtherDirection: =>
      newDirection = @oppositeDirection(@get('facing').direction)
      @set facing:
        oldDirection: @get('facing').direction
        direction: newDirection
        axis: @get('facing').axis
      @changeDirectionClass()

    changeDirectionClass: ->
      enemyObj = $("##{@get('id')}")
      enemyObj.removeClass(@get('facing').oldDirection)
      enemyObj.addClass(@get('facing').direction)

    checkCurrentDirection: (range) ->
      newLoc = @getLoc(range).find( (item) =>
        item.direction is @get('facing').direction
        )
      # console.log "this is the next square in direction", newLoc, @coords[@get('location')]
      currentLoc = @coords[@get('location')]
      newLoc = @buildLocation(currentLoc,newLoc)
      cell = @buildCellName(newLoc)
      cell

    pulse: (coords,player) ->
      @sensor = setInterval(@scanArea,@get('attackSpeed'))

    scanArea: =>
      if @get('alive') and @player.get('alive')
        enemyCoords = @coords[@get('location')]
        for x in [1..@get('range')]
          @checkLoc(@getLoc(x))
      else
        clearInterval(@sensor)

    checkLoc: (locArray) ->
      for item in locArray
        newLoc =
          x: @location.x + item.x
          y: @location.y + item.y
        if @playerChecker(newLoc)
          @attackPlayer()

    playerChecker: (newLoc) ->
      id = "#cell-#{newLoc.x}-#{newLoc.y}"
      if $(id).children().length
        object = $($(id).children()[0])
        if object.hasClass('player')
          true
        else
          false
      else
        false

    attackPlayer: =>
      if @get('target')
        if @checkPlayerStillInRange()
          playerHp = @player.get('health')
          console.log "before", playerHp
          playerHp -= @get('damage')
          @player.set health: playerHp
          @postDamage()

    postDamage: ->
      @checkPlayerStillInRange()
      if @player.get('health') < 1
        @player.set alive: false
      unless @player.get('alive') and @get('target')
        clearInterval(@swing)
      console.log "after", @player.get('health')

    checkPlayerStillInRange: ->
      if $('.player').parent().attr('id') is @get('target')
        return true
      else
        @set target: false
        return false

      #fire damage animation


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
