@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Player extends App.Entities.Model

    defaults:
      health: 5
      maxHealth: 5
      range: 1
      attackSpeed: 1000
      moveSpeed: 200
      shield: 3
      actionCd: false
      alive: true

    initialize: (options) ->
      { @map } = options
      @coords = @map.get('coordinates')
      @illegalMoves = ['wall','enemy']
      @damage =
        attack: 1
        fireBall: 2

    move: (keypress) ->
      @setActionCd(@get('moveSpeed'))
      location = @get('location')
      direction = @get('direction')
      @set oldLocation: location
      @set oldDirection: direction
      newCoords = "cell-"
      newDirection = "cell-"
      { key, axisChange, spaces } = keypress
      if @coords[location]
        cell = @coords[location]
        if key is "up" or key is "down"
          change = cell.x + (axisChange * spaces)
          newCoords += "#{(change).toString()}-#{(cell.y).toString()}"
          newDirection += "#{(change + axisChange).toString()}-#{(cell.y).toString()}"
        else if key is "left" or key is "right"
          change = cell.y + (axisChange * spaces)
          newCoords += "#{(cell.x).toString()}-#{(change).toString()}"
          newDirection += "#{(cell.x).toString()}-#{(change + axisChange).toString()}"
      else
        console.log "you're out of bounds", cell
      unless @coords[newCoords]
        newCoords = location
      @set facing: 
        direction: key
        axis: axisChange
      @checkIllegalMoves(newCoords,newDirection)
      @movePlayer()

     movePlayer: ->
      unless @get('location') is @get('oldLocation')
        playerObj = $(".player").clone()
        $(".player").remove()
        $("##{@get('location')}").append(playerObj)

    checkIllegalMoves: (newCoords,newDirection) ->
      if $($("##{newCoords}")[0].children[0]).hasAnyClass(@illegalMoves)
        @set location: @get('oldLocation')
        @set direction: newCoords
        console.log "Loc =>", @get('location'), "Dir =>", @get('direction')
      else
        @set direction: newDirection
        @set location: newCoords
      if $("##{@get('direction')}").length
        @set target: $("##{@get('direction')}")[0].children[0]
      else
        @set target: false
        console.log "Loc =>", @get('location'), "Dir =>", @get('direction')

    attack: (key, targetModel) ->
      @setActionCd(@get('attackSpeed'))
      @dealDamage("attack", targetModel)
      target = targetModel.get('name')
      targetHealth = $("##{target}").children()
      @modifyTargetHealth(targetHealth,targetModel)

    modifyTargetHealth: (targetHealth, model) ->
      targetHealth.each( (index, object) =>
        if (index+1) > model.get('health')
          $(object).removeClass('positive-health')
          $(object).addClass('negative-health')
        )
      @deadOrAlive(model)

    dealDamage: (type, target) ->
      damage = @damage[type]
      console.log "damage", damage
      enemyHp = target.get('health')
      enemyHp -= damage
      target.set alive: false if enemyHp < 1
      target.set health: enemyHp
    #fire damage animation 

    deadOrAlive: (targetModel) ->
      unless targetModel.get('alive')
        @cleanup(targetModel)

    cleanup: (model) ->
      console.log "cleanup this fulla",model
      $("##{model.get('name')}").remove()
      $("##{model.get('id')}").remove()
      @set target: false
      @get('enemies').remove(model)

    spell: (keypress, targetModel, callback) ->
      @setActionCd(@get('attackSpeed'))
      { key, spaces } = keypress
      if key is "Q"
        @fireBall(spaces)

    fireBall: (spaces) ->
      route = @getProjectileCoords(spaces)
      absoluteLoc = @getOffset($("##{@get('location')}")[0])
      fireballObj = "<div class='fireball' style='left:#{absoluteLoc.left+10}px;top:#{absoluteLoc.top+10}px;'></div>"
      destination = @getElementByLoc(route[route.length-1])
      $('body').append(fireballObj)
      @animateSpell('fireball', destination, route)

    animateSpell: (spell, destination, route) ->
      spellSpeed = 500
      @checkRoute(route,spell,spellSpeed)
      absoluteDest = @getOffset(destination[0])
      
      $(".#{spell}").animate(
        left: absoluteDest.left+10
        top: (absoluteDest.top+10)
        ,
        spellSpeed * route.length
        ,
        ->
          $(".#{spell}").remove()
        )

    checkRoute: (route,spell,spellSpeed) ->
      count = -1
      time = spellSpeed
      total = route.length
      simulateTravelTime = =>
        unless count < 0 or count > (route.length-1)
          cell = @getElementByLoc(route[count])
          if cell.children().length
            console.log "cell.children", cell.children()
            if cell.children()[0].classList[1] is "enemy"
              @hitTarget(cell,spell)
              return
            else
              @cleanupSpellSprite(spell)
              return
        if count >= total
          return
        else
          count++
        setTimeout simulateTravelTime, time
      simulateTravelTime()

    hitTarget: (target,spell) ->
      @cleanupSpellSprite(spell)
      @enemies = @get('enemies')
      target = @get('enemies').find( (enemy) ->
        enemy.get('id') is parseInt($(target.children()[0]).attr('id'))
        )
      @dealDamage("fireBall",target)
      healthBars = $("##{target.get('name')}").children()
      @modifyTargetHealth(healthBars, target)

    cleanupSpellSprite: (spell) ->
      $(".#{spell}").stop()
      $(".#{spell}").remove()

    getProjectileCoords: (spaces) ->
      array = []
      facing = @get('facing')
      range = @getRange(spaces, facing)
      currentLocation = @coords[@get('location')]
      for i in [1..range]
        if facing.direction is "up" or facing.direction is "down"
          temp = 
            x: currentLocation.x + facing.axis*i
            y: currentLocation.y
        else if facing.direction is "left" or facing.direction is "right"
          temp = 
            x: currentLocation.x
            y: currentLocation.y + facing.axis*i
        array.push(temp)
      array

    getRange: (spaces, facing) ->
      loc = @coords[@get('location')]
      x = loc.x
      y = loc.y
      range = 0
      for i in [1..spaces]
        switch facing.direction
          when "up"
            unless x is 1 
              x -= 1
              range += 1
          when "down"
            unless x is @map.get('size') 
              x += 1
              range += 1
          when "left"
            unless y is 1 
              y -= 1
              range += 1
          when "right"
            unless y is @map.get('size')
              y += 1
              range += 1
      range

    getElementByLoc: (loc) ->
      $("#cell-#{loc.x}-#{loc.y}")

    setActionCd: (time) ->
      @set actionCd: true
      setTimeout(@resetAction,time)

    resetAction: =>
      @set actionCd: false

  class LilrpgApp.Controls extends App.Entities.Model

    defaults:
      32:
        key: "space"
        action: "block"
        axisChange: 0
        spaces: 0
        code: 32
      37:
        key: "left"
        action: "move"
        axisChange: -1
        spaces: 1
        code: 37
      38:
        key: "up"
        action: "move"
        axisChange: -1
        spaces: 1
        code: 38
      39:
        key: "right"
        action: "move"
        axisChange: 1
        spaces: 1
        code: 39
      40:
        key: "down"
        action: "move"
        axisChange: 1
        spaces: 1
        code: 40
      81:
        key: "Q"
        action: "spell"
        axisChange: 0
        spaces: 3
        code: 81
      87:
        key: "W"
        action: "spell"
        axisChange: 0
        spaces: 1
        code: 87
      82:
        key: "R"
        action: "spell"
        axisChange: 0
        spaces: 3
        code: 82
      65:
        key: "A"
        action: "attack"
        axisChange: 0
        spaces: 1
        code: 65
      83:
        key: "S"
        action: "attack"
        axisChange: 0
        spaces: 3
        code: 83
      68:
        key: "D"
        action: "block"
        axisChange: 0
        spaces: 0
        code: 68

  API =
    player: (options) ->
      new LilrpgApp.Player options
    controls: ->
      new LilrpgApp.Controls

  App.reqres.setHandler "lilrpg:player:controls", ->
    API.controls()

  App.reqres.setHandler "lilrpg:player:entity", (options) ->
    API.player options 


