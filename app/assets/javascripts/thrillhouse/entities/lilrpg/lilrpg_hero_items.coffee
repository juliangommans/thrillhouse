@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.HeroItems extends App.Entities.Model
    urlRoot: -> Routes.hero_items_index_path()

  class LilrpgApp.HeroItemsCollection extends App.Entities.Collection
    model: LilrpgApp.HeroItems
    url: -> Routes.hero_items_index_path()

  API =
    getHeroItemsCollection: ->
      lilrpgs = new LilrpgApp.HeroItemsCollection
      lilrpgs.fetch
        reset: true
      lilrpgs
    getHeroItems: (id) ->
      lilrpg = new LilrpgApp.HeroItems
        id: id
      lilrpg.fetch()
      lilrpg
    newHeroItems: ->
      new LilrpgApp.HeroItems

  App.reqres.setHandler 'hero:items:entities', ->
    API.getHeroItemsCollection()

  App.reqres.setHandler 'hero:items:entity', (id) ->
    API.getHeroItems id

  App.reqres.setHandler 'new:hero:items:entity', ->
    API.newHeroItems()