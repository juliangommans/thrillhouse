@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Ability extends App.LilrpgApp.Spell
     defaults:
      cooldownMod: 1
      onCd: false
      range: 1
      damage: 1
      rotate: false
      rotateSpeed: 10
      stun: false
      pierce: false
      aoe: false
      multishot: 1
      confirmHit: false
      target: 'enemy'
      orbs: []
      targets: []
      uniqueId: "test-0"


  class LilrpgApp.Attack extends LilrpgApp.Ability

  class LilrpgApp.Shield extends LilrpgApp.Ability
    initialize:->
      @set
      	range: 0

  API =
    attack: ->
      new LilrpgApp.Attack

  App.reqres.setHandler "lilrpg:attack:spell", ->
    API.attack()