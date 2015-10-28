@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.Lilrpg extends App.Entities.Model
    urlRoot: -> Routes.lilrpg_index_path()

  class LilrpgApp.LilrpgCollection extends App.Entities.Collection
    model: LilrpgApp.Lilrpg
    url: -> Routes.lilrpg_index_path()

  API =
    getLilrpgs: ->
      lilrpgs = new LilrpgApp.LilrpgCollection
      lilrpgs.fetch
        reset: true
      lilrpgs
    getLilrpg: (id) ->
      lilrpg = new LilrpgApp.Lilrpg
        id: id
      lilrpg.fetch()
      lilrpg
    newLilrpg: ->
      new LilrpgApp.Lilrpg

  App.reqres.setHandler 'lilrpg:entities', ->
    API.getLilrpgs()

  App.reqres.setHandler 'lilrpg:entity', (id) ->
    API.getLilrpg id

  App.reqres.setHandler 'new:lilrpg:entity', ->
    API.newLilrpg()
