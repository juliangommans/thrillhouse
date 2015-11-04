@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Spell extends App.Entities.LilrpgModel

  class LilrpgApp.Fireball extends LilrpgApp.Spell

  	defaults:
  		range: 3
  		cooldown: 10000
  		speed: 500
  		damage: 2



  API =
  	fireball: ->
  		new LilrpgApp.Fireball

  App.reqres.setHandler "lilrpg:fireball:spell", ->
    API.fireball()