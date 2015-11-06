@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Player extends App.Entities.LilrpgModel

    defaults:
      health: 5
      maxHealth: 5
      range: 1
      actionSpeed: 750
      moveSpeed: 100
      shield: 3
      moveCd: false
      actionCd: false
      alive: true
      facing: {}

    initialize: (options) ->
      { @map } = options
      @coords = @map.get('coordinates')
      @illegalMoves = ['wall','enemy']
      @damage =
        attack: 1
        fireBall: 2
      @listenTo @, "change", @checkHealth
      fireball = App.request "lilrpg:fireball:spell"
      icicle = App.request "lilrpg:icicle:spell"
      thunderbolt = App.request "lilrpg:thunderbolt:spell"
      App.execute "when:fetched", [fireball,icicle,thunderbolt], =>
        @set spells:
          Q: fireball
          W: icicle
          E: thunderbolt
          # S: teleport
        console.log "spellses?", @get('spells')

    checkHealth: (args) ->
      healthBars = $('#player-health-bars').children()
      @modifyTargetHealth(healthBars, @)
      unless @get('alive')
        alert "bitch, you ded"

#### Movement methods ####

    move: (keypress) ->
      @setMoveCd(@get('moveSpeed'))
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
      @setFacing(key, axisChange)
      console.log "directions new-old", newDirection, @get('oldDirection')
      if @get('facing').direction is @get('facing').oldDirection
        @checkIllegalMoves(newCoords,newDirection)
        @movePlayer()
      else
        @set direction: newCoords

    setFacing: (key, axisChange) ->
      oldDirection = @get('facing').direction
      @set facing:
        oldDirection: oldDirection
        direction: key
        axis: axisChange
      $(".player").removeClass(@get("facing").oldDirection)
      $(".player").addClass(key)

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

#### Attack and Damage ####

    attack: (key, targetModel) ->
      @setActionCd(@get('actionSpeed'))
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
      unless model is @
        @deadOrAlive(model)

    dealDamage: (source, target) ->
      if source is "attack"
        damage = @damage[source]
      else
        damage = source.get('damage')
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
      console.log "cleanup, isle 6"
      $("##{model.get('name')}").remove()
      $("##{model.get('id')}").remove()
      @set target: false
      @get('enemies').remove(model)

#### Spells and Animations ####

    spell: (keypress, targetModel, callback) ->
      { key } = keypress
      spell = @get('spells')[key]
      unless spell.get('onCd')
        route = @getProjectileCoords(spell.get('range'))
        @setActionCd(@get('actionSpeed'))
        if spell.get('type') is "projectile"
          @projectileSpell(spell, route)
        else if spell.get('type') is "instant"
          console.log "you lightning bolted"
          @instantSpell(spell, route)

    projectileSpell: (spell, route) ->
      absoluteLoc = @getOffset($("##{@get('location')}")[0])
      domObject = "<div class='#{spell.get('className')}' style='left:#{absoluteLoc.left+5}px;top:#{absoluteLoc.top+5}px;'></div>"
      destination = @getElementByLoc(route[route.length-1])
      $('body').append(domObject)
      @animateProjectile(spell, destination, route)

    instantSpell: (spell, route) ->
      destination = @getElementByLoc(route[route.length-1])
      absoluteLoc = @getOffset($(destination)[0])
      domObject = "<div class='#{spell.get('className')}' style='left:#{absoluteLoc.left}px;top:#{absoluteLoc.top}px;'></div>"
      console.log "before the finding of targets", destination
      if destination.children().length
        if destination.children()[0].classList[1] is "enemy"
          target = destination

      @animateInstant(spell, domObject, target)

    animateProjectile: (spell, destination, route) ->
      @degree = 0
      className = spell.get('className')
      spellSpeed = spell.get('speed')
      @checkRoute(route,spell,spellSpeed)
      absoluteDest = @getOffset(destination[0])
      if spell.get('rotate')
        @rotate($(".#{className}"),spell.get('rotateSpeed'))

      $(".#{className}").animate(
        left: absoluteDest.left+5
        top: absoluteDest.top+5
        ,
        spellSpeed * route.length
        ->
          if spell.get('rotate')
            clearTimeout(@rotationTimer)
          $(".#{className}").remove()
        )

    animateInstant: (spell, domObject, target) ->
      extraDom = spell.get('extraDom')
      className = spell.get('className')
      console.log "BEGIN ZE ANIMATION", spell, domObject
      $('body').append(domObject)
      if extraDom?
        $(".#{className}").append(extraDom)

      if spell.get("target") is "player"
        $(".#{className}").fadeOut(spell.get("speed")
          , ->
            $(".#{className}").fadeIn(spell.get("speed"))
          )
      else
        $(".#{className}").fadeIn(spell.get("speed")*3
          , =>
            $(".#{className}").fadeOut(spell.get("speed")*3
              , =>
                if target?
                  @hitTarget(target, spell)
                else
                  @cleanupSpellSprite(spell.get('className'))
              )
          )


    checkRoute: (route,spell,spellSpeed) ->
      count = -1
      total = route.length
      simulateTravelTime = =>
        unless count < 0 or count > (route.length-1)
          cell = @getElementByLoc(route[count])
          if cell.children().length
            if cell.children()[0].classList[1] is "enemy"
              @hitTarget(cell,spell)
              return
            else
              @cleanupSpellSprite(spell.get('className'))
              return
        if count >= total
          return
        else
          count++
        setTimeout simulateTravelTime, spellSpeed
      simulateTravelTime()

    hitTarget: (target,spell) ->
      @cleanupSpellSprite(spell.get('className'))
      @enemies = @get('enemies')
      target = @findTargetModel(parseInt($(target.children()[0]).attr('id')))
      @dealDamage(spell,target)
      healthBars = $("##{target.get('name')}").children()
      @modifyTargetHealth(healthBars, target)

    findTargetModel: (identifier) ->
      @get('enemies').find( (enemy) ->
        enemy.get('id') is identifier
        )

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

#### Cooldowns and Timers ####

    setMoveCd: (time) ->
      @set moveCd: true
      setTimeout(@resetMove,time)

    setActionCd: (time) ->
      @set actionCd: true
      setTimeout(@resetAction,time)

    resetMove: =>
      @set moveCd: false

    resetAction: =>
      @set actionCd: false

  API =
    player: (options) ->
      new LilrpgApp.Player options

  App.reqres.setHandler "lilrpg:player:entity", (options) ->
    API.player options


