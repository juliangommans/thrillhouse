@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Spell extends App.Entities.LilrpgModel
    defaults:
      peirce: false
      onCd: false
      range: 3
      rotate: false
      rotateSpeed: 10
      stun: false
      pierce: false
      aoe: false
      multishot: false
      confirmHit: false
      target: 'enemy'
      orbs: []
      targets: []

    showCooldown: ->
      className = @get('className')
      $("##{className}").prepend("<div class='cooldown-animation #{className}-cd'></div>")
      $(".#{className}-cd").animate(
        width: "0px"
      ,
        @get('cooldown')
      ->
        @remove()
        )

    getRange: (map, facing, playerLoc) ->
      coords = map.get('coordinates')
      max = map.get('size')
      loc = coords[playerLoc]
      x = loc.x
      y = loc.y
      range = 0
      for i in [1..@get('range')]
        switch facing.direction
          when "up"
            unless x is 1
              x -= 1
              range += 1
          when "down"
            unless x is max
              x += 1
              range += 1
          when "left"
            unless y is 1
              y -= 1
              range += 1
          when "right"
            unless y is max
              y += 1
              range += 1
      range

  class LilrpgApp.Fireball extends LilrpgApp.Spell
    initialize:->
      @set
        pierce: true
        aoe: true
        className: "fireball"
        cooldown: 1200
        speed: 325
        damage: 2
        type: 'projectile'

  class LilrpgApp.Icicle extends LilrpgApp.Spell
    initialize:->
      @set
        pierce: true
        aoe: true
        className: "icicle"
        cooldown: 1000
        speed: 275
        damage: 1
        stun: true
        type: 'projectile'
        rotate: true
    #### higher rotate speed is faster rotation animation
    #### basically how many degrees change per milisecond

  class LilrpgApp.ThunderBolt extends LilrpgApp.Spell
    initialize:->
      @set
        aoe: true
        className: "thunderbolt"
        cooldown: 600
        speed: 50
        damage: 1
        type: 'instant'
        extraDom: "<div class='lightning-left'></div><div class='lightning-right'></div>"

   class LilrpgApp.Teleport extends LilrpgApp.Spell
    initialize:->
      @set
        className: "teleport"
        cooldown: 6000
        speed: 100
        damage: 0
        type: 'instant'
        target: 'player'
        # extraDom: "<div class='left'></div><div class='right'></div>"

  API =
    fireball: ->
      new LilrpgApp.Fireball
    icicle: ->
      new LilrpgApp.Icicle
    thunderbolt: ->
      new LilrpgApp.ThunderBolt
    teleport: ->
      new LilrpgApp.Teleport

  App.reqres.setHandler "lilrpg:fireball:spell", ->
    API.fireball()

  App.reqres.setHandler "lilrpg:icicle:spell", ->
    API.icicle()

  App.reqres.setHandler "lilrpg:thunderbolt:spell", ->
    API.thunderbolt()

  App.reqres.setHandler "lilrpg:teleport:spell", ->
    API.teleport()
