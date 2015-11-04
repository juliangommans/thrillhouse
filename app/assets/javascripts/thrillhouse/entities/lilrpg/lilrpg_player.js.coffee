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

    initialize: (map) ->
      @map = map
      @coords = map.get('coordinates')
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
        console.log "you tried to move out of bounds", newCoords
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
      console.log "for sanity here is your target", @get('target').classList
      @dealDamage(key, targetModel)
      target = $(@get('target')).data('name')
      targetHealth = $("##{target}").children()
      targetHealth.each( (index, object) =>
        if (index+1) > targetModel.get('health')
          $(object).removeClass('positive-health')
          $(object).addClass('negative-health')
        else 
          console.log "there should be less health", object
        )

    spell: (keypress, targetModel, callback) ->
      @setActionCd(@get('attackSpeed'))
      { key, spaces } = keypress
      console.log "you are facing", @get('facing')
      if key is "Q"
        @fireBall(spaces)

    fireBall: (spaces) ->
      facing = @get('facing')
      loc = @coords[@get('location')]
      distance = spaces*facing.axis
      console.log "loc & distance", loc, distance
      if facing.direction is "up" or facing.direction is "down"
        loc.x += distance
      else if facing.direction is "left" or facing.direction is "right"
        loc.y += distance
      absoluteLoc = @getOffset($("##{@get('location')}")[0])
      fireballObj = "<div class='fireball' style='left:#{absoluteLoc.left+10}px;top:#{absoluteLoc.top+10}px;'></div>"
      destination = @getElementByLoc(loc)
      $('body').append(fireballObj)
      @animateSpell(fireballObj, destination)

    animateSpell: (spell,destination) ->
      console.log "destination", destination[0], "location", $("##{@get('location')}")[0]
      absoluteDest = @getOffset(destination[0])
      
      $('.fireball').animate(
        left: absoluteDest.left+10
        top: (absoluteDest.top+10)
        ,
        3000
        ,
        ->
          $('.fireball').remove()
        )

    getElementByLoc: (loc) ->
      if loc.x < 1
        loc.x = 1
      if loc.y < 1
        loc.y = 1
      if loc.x > @map.get('size')
        loc.x = @map.get('size') 
      if loc.y > @map.get('size') 
        loc.y = @map.get('size') 
      $("#cell-#{loc.x}-#{loc.y}")

    dealDamage: (key, target) ->
      damage = @damage[key.action]
      enemyHp = target.get('health')
      enemyHp -= damage
      target.set alive: false if enemyHp < 1
      target.set health: enemyHp
    #fire damage animation 

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
    player: (map) ->
      new LilrpgApp.Player map
    controls: ->
      new LilrpgApp.Controls

  App.reqres.setHandler "lilrpg:player:controls", ->
    API.controls()

  App.reqres.setHandler "lilrpg:player:entity", (map) ->
    API.player(map)


