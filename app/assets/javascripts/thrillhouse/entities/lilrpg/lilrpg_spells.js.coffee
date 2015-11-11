@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Spell extends App.Entities.LilrpgModel

    showCooldown: ->
      className = @get('className')
      $("##{className}").prepend("<div class='cooldown-animation #{className}-cd'></div>")
      $(".#{className}-cd").animate(
        width: "0px"
      ,
        @get('cooldown')
      ->
        console.log "this is", @
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

    defaults:
      className: "fireball"
      range: 3
      cooldown: 10000
      speed: 500
      damage: 2
      stun: false
      onCd: false
      type: 'projectile'
      target: 'enemy'
      rotate: false

  class LilrpgApp.Icicle extends LilrpgApp.Spell

    defaults:
      className: "icicle"
      range: 3
      cooldown: 8000
      speed: 400
      damage: 1
      stun: true
      onCd: false
      type: 'projectile'
      target: 'enemy'
      rotate: true
  #### higher rotate speed is faster rotation animation
  #### basically how many degrees change per milisecond
      rotateSpeed: 10


  class LilrpgApp.ThunderBolt extends LilrpgApp.Spell

    defaults:
      className: "thunderbolt"
      range: 3
      cooldown: 4000
      speed: 100
      damage: 1
      stun: false
      onCd: false
      type: 'instant'
      target: 'enemy'
      extraDom: "<div class='lightning-left'></div><div class='lightning-right'></div>"
      rotate: false

   class LilrpgApp.Teleport extends LilrpgApp.Spell

    defaults:
      className: "teleport"
      range: 3
      cooldown: 2000
      speed: 100
      damage: 0
      stun: false
      onCd: false
      type: 'instant'
      target: 'player'
      # extraDom: "<div class='left'></div><div class='right'></div>"
      rotate: false


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