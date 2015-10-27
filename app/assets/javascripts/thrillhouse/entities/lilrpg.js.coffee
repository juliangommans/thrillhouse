@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Lilrpg extends App.Entities.Model
    urlRoot: -> Routes.lilrpg_index_path()

  class Entities.LilrpgCollection extends App.Entities.Collection
    model: Entities.Lilrpg
    url: -> Routes.lilrpg_index_path()

  API =
    getLilrpgs: ->
      lilrpgs = new Entities.LilrpgCollection
      lilrpgs.fetch
        reset: true
      lilrpgs
    getLilrpg: (id) ->
      lilrpg = new Entities.Lilrpg
        id: id
      lilrpg.fetch()
      lilrpg
    newLilrpg: ->
      new Entities.Lilrpg

  App.reqres.setHandler 'lilrpg:entities', ->
    API.getLilrpgs()

  App.reqres.setHandler 'lilrpg:entity', (id) ->
    API.getLilrpg id

  App.reqres.setHandler 'new:lilrpg:entity', ->
    API.newLilrpg()