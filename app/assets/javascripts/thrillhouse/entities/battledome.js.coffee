@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Battledome extends App.Entities.Model
    urlRoot: -> Routes.battledome_index_path()

  class Entities.BattledomeCollection extends App.Entities.Collection
    model: Entities.Battledome
    url: -> Routes.battledome_index_path()

  API =
    getBattledomes: ->
      battledomes = new Entities.BattledomeCollection
      battledomes.fetch
        reset: true
      battledomes
    getBattledome: (id) ->
      battledome = new Entities.Battledome
        id: id
      battledome.fetch()
      battledome
    newBattledome: ->
      new Entities.Battledome

  App.reqres.setHandler 'battledome:entities', ->
    API.getBattledomes()

  App.reqres.setHandler 'battledome:entity', (id) ->
    API.getBattledome id

  App.reqres.setHandler 'new:battledome:entity', ->
    API.newBattledome()