@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Spell extends App.Entities.LilrpgModel

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

  class LilrpgApp.ThunderBolt extends LilrpgApp.Spell

    defaults:
      className: "thunderbolt"
      range: 3
      cooldown: 4000
      speed: 300
      damage: 1
      stun: false
      onCd: false
      type: 'instant'
      target: 'enemy'
      extraDom: "<div class='left'></div><div class='right'></div>"

  API =
    fireball: ->
      new LilrpgApp.Fireball
    icicle: ->
      new LilrpgApp.Icicle
    thunderbolt: ->
      new LilrpgApp.ThunderBolt

  App.reqres.setHandler "lilrpg:fireball:spell", ->
    API.fireball()

  App.reqres.setHandler "lilrpg:icicle:spell", ->
    API.icicle()

  App.reqres.setHandler "lilrpg:thunderbolt:spell", ->
    API.thunderbolt()
