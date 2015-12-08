@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.Abilities extends App.Entities.Collection

  class LilrpgApp.Ability extends App.Entities.Spell

  class LilrpgApp.Attack extends LilrpgApp.Ability
    initialize:->
      @set
        className: "attack"
        cooldown: 750
        speed: 75
        range: 1
        type: "projectile"
        target: "enemy"

  class LilrpgApp.Blast extends LilrpgApp.Ability
    initialize:->
      @set
        className: "blast"
        cooldownBase: 12000
        cooldown: 12000
        range: 1
        damage: 2
        speed: 133
        aoe: true
        stun: true
        type: "instant"
        target: "enemy"

  class LilrpgApp.Shield extends LilrpgApp.Ability
    initialize:->
      @set
        cooldownBase: 15000
        cooldown: 15000
        className: "shield"
        damage: 0
        block: 2
        range: 0
        speed: 5000
        type: "instant"
        target: "player"

  class LilrpgApp.Lift extends LilrpgApp.Ability
    initialize:->
      @set
        className: "lift"
        range: 1
        type: "instant"
        target: "enemy"

  API =
    attack: ->
      new LilrpgApp.Attack
    blast: ->
      new LilrpgApp.Blast
    shield: ->
      new LilrpgApp.Shield
    lift: ->
      new LilrpgApp.Lift
    abilities: ->
      new LilrpgApp.Abilities([
        API.attack(),
        API.blast(),
        API.shield(),
        API.lift()
        ])

  App.reqres.setHandler "lilrpg:ability:entities", ->
    API.abilities()

  App.reqres.setHandler "lilrpg:lift:ability", ->
    API.lift()

  App.reqres.setHandler "lilrpg:shield:ability", ->
    API.shield()

  App.reqres.setHandler "lilrpg:blast:ability", ->
    API.blast()

  App.reqres.setHandler "lilrpg:attack:ability", ->
    API.attack()
