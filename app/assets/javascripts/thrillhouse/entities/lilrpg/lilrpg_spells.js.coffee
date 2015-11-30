@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.Spells extends App.Entities.Collection

  class LilrpgApp.Fireball extends App.Entities.Spell
    initialize:->
      @set
        className: "fireball"
        cooldownBase: 10000
        cooldown: 10000
        speed: 325
        range: 4
        damage: 2
        type: 'projectile'

  class LilrpgApp.Icicle extends App.Entities.Spell
    initialize:->
      @set
        className: "icicle"
        cooldownBase: 9000
        cooldown: 9000
        speed: 275
        damage: 1
        stun: true
        type: 'projectile'
        rotate: true
    #### higher rotate speed is faster rotation animation
    #### basically how many degrees change per milisecond

  class LilrpgApp.ThunderBolt extends App.Entities.Spell
    initialize:->
      @set
        range: 2
        className: "thunderbolt"
        cooldownBase: 7000
        cooldown: 7000
        speed: 100
        damage: 1
        type: 'instant'
        extraDom: "<div class='lightning-left'></div><div class='lightning-right'></div>"

   class LilrpgApp.Teleport extends App.Entities.Spell
    initialize:->
      @set
        className: "teleport"
        cooldownBase: 6000
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
    spells: ->
      new LilrpgApp.Spells([
        API.fireball(),
        API.icicle(),
        API.thunderbolt(),
        API.teleport()
        ])

  App.reqres.setHandler "lilrpg:spell:entities", ->
    API.spells()

  App.reqres.setHandler "lilrpg:fireball:spell", ->
    API.fireball()

  App.reqres.setHandler "lilrpg:icicle:spell", ->
    API.icicle()

  App.reqres.setHandler "lilrpg:thunderbolt:spell", ->
    API.thunderbolt()

  App.reqres.setHandler "lilrpg:teleport:spell", ->
    API.teleport()
