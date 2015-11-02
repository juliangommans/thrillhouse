@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Enemy extends App.Entities.Model

    getElement: ->
      $(document).find("[data-name=#{@get('name')}]")

  class LilrpgApp.SimpleMeleeEnemy extends LilrpgApp.Enemy
    defaults:
      health: 3
      maxHealth: 3
      damage: 1
      range: 1
      alive: true
      name: "TestSubject"

  class LilrpgApp.SimpleRangedEnemy extends LilrpgApp.Enemy
    defaults:
      health: 2
      maxHealth: 2
      damage: 1
      range: 3
      alive: true
      name: "TestSubject"

  API =
    simpleMeleeEnemy: ->
      new LilrpgApp.SimpleMeleeEnemy
    simpleRangedEnemy: ->
      new LilrpgApp.SimpleRangedEnemy

  App.reqres.setHandler "lilrpg:simple-melee:enemy", ->
    API.simpleMeleeEnemy()
    
  App.reqres.setHandler "lilrpg:simple-ranged:enemy", ->
    API.simpleRangedEnemy()