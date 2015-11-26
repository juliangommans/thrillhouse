@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Player extends App.Entities.LilrpgModel

    defaults:
      damage: 1
      spellStats:
        damage: 0
        range: 0
        cooldownMod: 0
        multishot: 0
      abilityStats:
        damage: 0
        range: 0
        cooldownMod: 0
        multishot: 0
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
      @aoeCount = 0
      { @map, @hero } = options
      @spellCount = 0
      @coords = @map.get('coordinates') if @map?

      @listenTo @, "change", @checkHealth
      fireball = App.request "lilrpg:fireball:spell"
      icicle = App.request "lilrpg:icicle:spell"
      thunderbolt = App.request "lilrpg:thunderbolt:spell"
      teleport = App.request "lilrpg:teleport:spell"
      spellArray = [fireball,icicle,thunderbolt,teleport]
      spellCollection = new App.Entities.Collection
      @getClassBonus()

      App.execute "when:fetched", spellArray, =>
        @set spells:
          Q: fireball
          W: icicle
          E: thunderbolt
          S: teleport
        spellCollection.add spellArray
        for spell in spellArray
          @updateSpells(spell)

        @set spellCollection: spellCollection
        console.log "spellses?", @get('spells')
        console.log "hero/player info", @

    updateSpells: (spell) ->
      @assignSpellOrbs(spell)
      @updateOrbs(spell)
      @updateFromHero(spell)
      spell.uniqueId(@spellCount)
      spell.setCooldown()

    updateOrbs: (spell) ->
      orbs = spell.get('orbs')
      for orb in orbs
        stat = orb.spell_stat
        change = spell.get(orb.spell_stat)
        if orb.item_colour is "amythest" or orb.item_colour is"emerald"
          change = true
          spell.set(stat, change)
        else
          change += orb.change
          spell.set(stat, change)

    updateFromHero: (spell) ->
      heroStats = @get('spellStats')
      spell.set damage: (spell.get('damage') + heroStats.damage)
      spell.set range: (spell.get('range') + heroStats.range)
      spell.set multishot: (spell.get('multishot') + heroStats.multishot)
      spell.set cooldownMod: (spell.get('cooldownMod') + heroStats.cooldownMod)

    assignSpellOrbs: (spell) ->
      invs = @get('hero').get('hero_inventories')
      spell.set orbs: _.filter(invs, (item) ->
        return item if item.spell is spell.get('className'))

    getClassBonus: ->
      switch @get('hero').get('hero_class')
        when "Fighter"
          newHealth = @get('health')+2
          newDamage = @get('damage')+1
          @fighterBonus(newHealth,newDamage)
        when "Wizard"
          spellDamage = @get('spellStats').damage + 1
          spellRange = 1
          spellCooldown = -0.15
          @wizardBonus(spellDamage,spellRange,spellCooldown)

    fighterBonus: (hp,dmg) ->
      @set health: hp
      @set maxHealth: hp
      @set damage: dmg

    wizardBonus: (dmg,range,cd) ->
      stat = @get('spellStats')
      stat.damage = dmg
      stat.range = range
      stat.cooldownMod = cd

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
      else
        @set direction: newDirection
        @set location: newCoords
      @changeTarget()

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
      console.log "this is a standard attack"
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
      stunned = false
      if target?
        if source is "attack"
          damage = @get('damage')
          @physicalDamage(source, target, damage)
        else
          damage = source.get('damage')
          stunned = source.get('stun')
          @magicalDamage(source, target, damage, stunned)

    physicalDamage: (source, target, damage) ->
        enemyHp = target.get('health')
        enemyHp -= damage
        target.set alive: false if enemyHp < 1
        target.set health: enemyHp

    magicalDamage: (source, target, damage, stunned) ->
      console.log "damage", damage, source.get('uniqueId'), target
      if source.checkTargets(target) or !source.get('dummy')
        enemyHp = target.get('health')
        enemyHp -= damage
        @stunTarget(target) if stunned
        target.set alive: false if enemyHp < 1
        target.set health: enemyHp
        unless source.get('pierce') or source.get('dummy')
          @cleanupSpellSprite(source)
      else
        console.log "^^^^^target is not eligible for some reason", target
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
        route = @getProjectileCoords(spell)
        @setActionCd(@get('actionSpeed'))
        @sortSpell(spell, route)

    castSpell: (spell, route) ->
      newSpell = @createNewSpell(spell)
      if newSpell.get('type') is "projectile"
        @projectileSpell(newSpell, route)
      else if newSpell.get('type') is "instant"
        @instantSpell(newSpell, route)

    createNewSpell: (spell) ->
      @spellCount += 1
      newSpell = spell.clone()
      newSpell.set(spell.attributes)
      newSpell.uniqueId(@spellCount)
      newSpell.set targets: []
      newSpell

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
      @animateProjectile(spell, route, destination)

    instantPierce: (spell, route) =>
      count = 1
      total = route.length
      spellDelay = =>
        console.log "this should only happen 3 times", count, spell
        newSpell = @createNewSpell(spell)
        destination = @getElementByLoc(route[count-1])
        @castInstant(newSpell, route, destination)
        if count >= total
          return
        else
          count++
        setTimeout spellDelay, (100)
      spellDelay()

    instantSpell: (spell, route) ->
      if spell.get('pierce')
        @instantPierce(spell, route)
      else
        destination = @getElementByLoc(route[route.length-1])
        @castInstant(spell, route, destination)

    castInstant: (spell, route, destination) ->
      if spell.get('className') is "teleport"
        @teleport(spell,route)
      else
        absoluteLoc = @getOffset($(destination)[0])
        domObject = "<div id='#{spell.get('uniqueId')}' class='#{spell.get('className')}' style='left:#{absoluteLoc.left}px;top:#{absoluteLoc.top}px;'></div>"

        @animateInstant(spell, domObject, destination)

    animateProjectile: (spell, route, destination) ->
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
      console.log "instantly animated"
      extraDom = spell.get('extraDom')
      className = spell.get('className')
      $('body').append(domObject)
      if extraDom?
        $(".#{className}").append(extraDom)

      $(".#{className}").fadeIn(spell.get("speed")*3
        , =>
          $(".#{className}").fadeOut(spell.get("speed")*4
            , =>
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
      count = 0
      total = spell.get('speed')
      milisecondCellChecker = =>
        if cell.children().length
          if @checkCurrentCell(cell, spell)
            return
          else
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
        console.log "=== AOE damaged target", cell, spell.get('uniqueId')
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
      @aoeCount += 1
      console.log 'aoe spell', @aoeCount, @spellCount
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
      newSpell = spell.clone()
      newSpell.set(spell.attributes)
      newSpell.uniqueId("#{cell.x}-#{cell.y}")
      newSpell.set dummy: true
      newSpell.set pierce: false
      newSpell.set aoe: false
      newSpell.set targets: []
      newSpell

    hitTarget: (cell,spell) ->
      @enemies = @get('enemies')
      target = @findTargetModel(parseInt($(cell.children()[0]).attr('id')))
      if target?
        unless spell.checkTargets(target)
          if spell.get('aoe')
            @applyAoe(cell, spell)
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
