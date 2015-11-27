@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.Abilities extends App.Entities.Collection

  class LilrpgApp.Ability extends App.Entities.Spell

  class LilrpgApp.Attack extends LilrpgApp.Ability
    initialize:->
      @set
        className: "attack"
        speed: 50
        range: 1
        type: "projectile"
        target: "enemy"


  class LilrpgApp.Blast extends LilrpgApp.Ability
    initialize:->
      @set
        className: "blast"
        range: 2
        damage: 2
        stun: true
        type: "projectile"
        target: "enemy"

  class LilrpgApp.Shield extends LilrpgApp.Ability
    initialize:->
      @set
        className: "shield"
        range: 0
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
