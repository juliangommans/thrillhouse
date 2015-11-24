@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Player extends App.Entities.LilrpgModel

    defaults:
      health: 5
      maxHealth: 5
      range: 1
      actionSpeed: 750
      moveSpeed: 150
      shield: 3
      moveCd: false
      actionCd: false
      alive: true
      facing: {}

    initialize: (options) ->
      { @map } = options
      @spellCount = 0
      @coords = @map.get('coordinates') if @map?
      @damage =
        attack: 1
      @listenTo @, "change", @checkHealth
      fireball = App.request "lilrpg:fireball:spell"
      icicle = App.request "lilrpg:icicle:spell"
      thunderbolt = App.request "lilrpg:thunderbolt:spell"
      teleport = App.request "lilrpg:teleport:spell"
      spellArray = [fireball,icicle,thunderbolt,teleport]
      spellCollection = new App.Entities.Collection

      @buildInventory()

      App.execute "when:fetched", spellArray, =>
        @set spells:
          Q: fireball
          W: icicle
          E: thunderbolt
          S: teleport
        spellCollection.add spellArray
        for spell in spellArray
          spell.uniqueId(@spellCount)
        @set spellCollection: spellCollection
        console.log "spellses?", @get('spells')

    updateSpells: ->
      spells = @get('spells')
      for k,spell of spells
        orbs = spell.get('orbs')
        for orb in orbs
          x = orb.spell_stat
          change = spell.get(orb.spell_stat)
          if orb.item_colour is "sapphire"
            change *= orb.change
          else
            change += orb.change
          spell.set(orb.spell_stat, change)
      console.log "PLAYA PLAYA", @


    checkHealth: (args) ->
      healthBars = $('#player-health-bars').children()
      @modifyTargetHealth(healthBars, @)
      unless @get('alive')
        console.log "bitch, you ded"
    checkCss: ->
      player = $('.player')
      if player.css('opacity')?
        player.css('opacity', "1")

    changeTarget: ->
      if $("##{@get('direction')}").length
        @set target: $("##{@get('direction')}")[0].children[0]
      else
        @set target: false

    sanityCheck: (targetModel) ->
      bool = false
      if targetModel?
        if @get('target').classList[1] is "enemy"
          bool = true
      bool

    getTargetModel: ->
      target = @get('target')
      if target?
        if $(target).children().length
          @findTargetModel(parseInt($(target).attr('id')))

    buildInventory: ->
      items = @get('hero_items')
      filtered = @uniqueArrayFilter(items,'id')
      inventory = []
      for item in filtered
        count = _.filter(items, (i) ->
          i.id is item.id)
        inventory.push {
          id: item.id
          name: item.name
          type: item.category
          colour: item.colour
          spell: item.spell
          className: "#{item.colour} #{item.category}"
          description: item.description
          total: count.length
        }
      @set inventory: inventory

#### Movement methods ####

    move: (keypress) ->
      @checkCss()
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
      # console.log "directions new-old", newDirection, @get('oldDirection')
      if @get('facing').direction is @get('facing').oldDirection
        @confirmMove(newCoords,newDirection)
        @movePlayer()
      else
        @set direction: newCoords
        @changeTarget()

    confirmMove: (newCoords,newDirection) ->
     if @checkIllegalMoves(newCoords)
        @set location: @get('oldLocation')
        @set direction: newCoords
        # console.log "Loc =>", @get('location'), "Dir =>", @get('direction')
      else
        @set direction: newDirection
        @set location: newCoords
      @changeTarget()
        # console.log "Loc =>", @get('location'), "Dir =>", @get('direction')

    setFacing: (key, axisChange) ->
      oldDirection = @get('facing').direction
      @set facing:
        oldDirection: oldDirection
        direction: key
        axis: axisChange
      $(".player").removeClass(@get("facing").oldDirection)
      $(".player").addClass(key)
      # @changeTarget()

    movePlayer: ->
      unless @get('location') is @get('oldLocation')
        playerObj = $(".player").clone()
        $(".player").remove()
        $("##{@get('location')}").append(playerObj)

#### Attack and Damage ####

    attack: (key) ->
      @changeTarget()
      targetModel = @getTargetModel()
      if @sanityCheck(targetModel)
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
      console.log "==source and target==", source, target
      stunned = false
      if source is "attack"
        damage = @damage[source]
      else
        damage = source.get('damage')
        stunned = source.get('stun')
      console.log "damage", damage
      if target?
        if source.checkTargets(target) or !source.get('dummy') #target.get('eligible')
          enemyHp = target.get('health')
          enemyHp -= damage
          @stunTarget(target) if stunned
          target.set alive: false if enemyHp < 1
          target.set health: enemyHp
          # target.set eligible: false
          unless source.get('pierce') or source.get('dummy')
            @cleanupSpellSprite(source)
        else
          console.log "target is not eligible for some reason", target
      #fire damage animation

    deadOrAlive: (targetModel) ->
      unless targetModel.get('alive')
        @cleanup(targetModel)

    cleanup: (model) ->
      console.log "cleanup, isle 6"
      clearInterval(model.swing)
      $("##{model.get('name')}").remove()
      $(".#{model.get('name')}").remove()
      $("##{model.get('id')}").remove()
      @set target: false
      @get('enemies').remove(model)

#### Spells and Animations ####

    spell: (keypress) ->
      { key } = keypress
      spell = @get('spells')[key]
      unless spell.get('onCd')
        console.log spell.get('className'), spell
        spell.set targets: []
        spell.set confirmHit: false
        @spellCd(spell)
        #### ConfirmHit is fine eligible seems to not be being removed from pierce
        route = @getProjectileCoords(spell)
        @setActionCd(@get('actionSpeed'))
        @sortSpell(spell, route)

    castSpell: (spell, route) ->
      @spellCount += 1
      newSpell = spell.clone()
      newSpell.set(spell.attributes)
      newSpell.uniqueId(@spellCount)
      if newSpell.get('type') is "projectile"
        @projectileSpell(newSpell, route)
      else if newSpell.get('type') is "instant"
        @instantSpell(newSpell, route)

    sortSpell: (spell, route) =>
      count = 1
      total = spell.get('multishot')
      spellDelay = =>
        @castSpell(spell, route)
        if count >= total
          return
        else
          count++
        setTimeout spellDelay, (400)
      spellDelay()

    projectileSpell: (spell, route) ->
      absoluteLoc = @getOffset($("##{@get('location')}")[0])
      domObject = "<div id='#{spell.get('uniqueId')}' class='#{spell.get('className')}' style='left:#{absoluteLoc.left+5}px;top:#{absoluteLoc.top+5}px;'></div>"
      destination = @getElementByLoc(route[route.length-1])
      $('body').append(domObject)
      @animateProjectile(spell, destination, route)

    instantSpell: (spell, route) ->
      destination = @getElementByLoc(route[route.length-1])
      if spell.get('className') is "teleport"
        @teleport(spell,route)
      else
        absoluteLoc = @getOffset($(destination)[0])
        domObject = "<div id='#{spell.get('uniqueId')}' class='#{spell.get('className')}' style='left:#{absoluteLoc.left}px;top:#{absoluteLoc.top}px;'></div>"
        # if destination.children().length
        #   if destination.children()[0].classList[1] is "enemy"
        #     target = destination

        @animateInstant(spell, domObject, destination)

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
        =>
          if spell.get('rotate')
            clearTimeout(@rotationTimer)
          @cleanupSpellSprite(spell)
        )

    animateInstant: (spell, domObject, target) ->
      extraDom = spell.get('extraDom')
      className = spell.get('className')
      $('body').append(domObject)
      if extraDom?
        $(".#{className}").append(extraDom)

      $(".#{className}").fadeIn(spell.get("speed")*2
        , =>
          $(".#{className}").fadeOut(spell.get("speed")*3
            , =>
              if spell.get('aoe')
                @applyAoe(target, spell)
              if target.children().length
                if target.children()[0].classList[1] is "enemy"
                  @hitTarget(target, spell)
                else
                  @cleanupSpellSprite(spell)
              else
                @cleanupSpellSprite(spell)
            )
        )

    teleport: (spell,route) ->
      speed = spell.get("speed")
      $(".player").fadeOut(speed*5
        , =>
          @checkRoute(route, spell, speed)
        )

    movePlayerInstantly: (cell, spell) ->
      playerIcon = $(".player").clone()
      $(".player").remove()
      cell.append(playerIcon)
      $(".player").fadeIn(spell.get("speed")*5)
      @set location: $(cell.attr('id'))

    realtimeCounter: (cell,spell) =>
      clearTimeout(@suicideTimeout)
      console.log "we are checking our squares"
      count = 0
      total = spell.get('speed')
      milisecondCellChecker = =>
        if cell.children().length
          if @checkCurrentCell(cell, spell)
            console.log "we hit it in the milisecondCellChecker"
            return
          else
            console.log "-------------we hit nothing"
            return
        if count >= total
          return
        else
          count++
        @suicideTimeout = setTimeout milisecondCellChecker, 1
      milisecondCellChecker()

    checkRoute: (route,spell,spellSpeed) ->
      count = -1
      total = route.length
      simulateTravelTime = =>
        return if spell.get('confirmHit')
        unless count < 0 or count > (route.length-1)
          cell = @getElementByLoc(route[count])
          if spell.get('className') is "teleport"
            if cell.children().length
              if count > 0
                previousCell = @getElementByLoc(route[count - 1])
                @checkCurrentCell(previousCell, spell)
                return
              else
                @checkCurrentCell($("##{@get('location')}"), spell)
                return
          else if spell.get('type') is "projectile"
            @realtimeCounter(cell,spell)
        if count >= total
          if spell.get('className') is "teleport"
            cell = @getElementByLoc(route[count-1])
            @checkCurrentCell(cell, spell)
            return
          else
            return
        else
          count++
        setTimeout simulateTravelTime, spellSpeed
      simulateTravelTime()

    checkCurrentCell: (cell, spell) ->
      if cell.children().length
        check = cell.children()[0].classList[1]
      if check is "enemy" or check is "dummy"
        if spell.get('aoe')
          @applyAoe(cell, spell)
        unless spell.get('pierce')
          spell.set confirmHit: true
        @hitTarget(cell,spell)
        return true
      else if spell.get('className') is "teleport"
        @movePlayerInstantly(cell, spell)
      else if check is "wall"
        unless spell.get('dummy')
          console.log "we hit a", check, "with", spell
          spell.set confirmHit: true
          @cleanupSpellSprite(spell)
        spell.set confirmHit: true
        return true
      else
        return false

    applyAoe: (cell, spell) ->
      # ATM aoe appears to  be cloning everything - including the animation - spamming the system.
      cellLoc = @coords[cell.attr('id')]
      cells = @createAoeCells(cellLoc,1)
      for newCell in cells
        newSpell = @buildDummySpell(newCell, spell)
        @animateAoe(newCell, newSpell)

    animateAoe: (cell, spell) ->
      cell = $("#cell-#{cell.x}-#{cell.y}")
      div = "<div id='#{spell.get('uniqueId')}' class='aoe-wrapper'>"
      div += "<div class='aoe aoe-#{spell.get('className')}'>"
      div += "</div></div>"
      cell.append(div)
      if cell.children().length
        @checkCurrentCell(cell, spell)
      $(".aoe-wrapper").fadeIn(spell.get('speed')
        , =>
          $(".aoe-wrapper").fadeOut(spell.get('speed')*2
            , =>
              @cleanupSpellSprite(spell)
              $(".aoe-wrapper").remove()
            )
        )

    buildDummySpell: (cell, spell) ->
      # animations seem to whack out
      newSpell = spell.clone()
      newSpell.set(spell.attributes)
      newSpell.uniqueId("#{cell.x}-#{cell.y}")
      newSpell.set dummy: true
      newSpell.set pierce: false
      newSpell.set aoe: false
      newSpell

    hitTarget: (target,spell) ->
      @enemies = @get('enemies')
      target = @findTargetModel(parseInt($(target.children()[0]).attr('id')))
      if target?
        spell.get('targets').push(target)
        @dealDamage(spell,target)
        healthBars = $("##{target.get('name')}").children()
        @modifyTargetHealth(healthBars, target)

    findTargetModel: (identifier) ->
      @get('enemies').find( (enemy) ->
        enemy.get('id') is identifier
        )

    getProjectileCoords: (spell) ->
      spaces = spell.get('range')
      array = []
      facing = @get('facing')
      range = spell.getRange(@map, facing, @get('location'))
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

#### Cooldowns and Timers ####

    spellCd: (spell) ->
      spell.set onCd: true
      spell.showCooldown()
      setTimeout( =>
        @resetSpell(spell)
      , spell.get('cooldown'))

    stunTarget: (target) ->
      target.set stunned: true
      setTimeout( =>
        @resetTarget(target)
      , 2000)

    resetSpell: (spell) =>
      spell.set onCd: false

    resetTarget: (target) =>
      target.set stunned: false

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
