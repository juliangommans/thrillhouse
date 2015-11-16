@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.HeroItems extends App.Entities.Model
    urlRoot: -> Routes.hero_items_path()

  class LilrpgApp.HeroItemsCollection extends App.Entities.Collection
    model: LilrpgApp.HeroItems
    url: -> Routes.hero_items_path()

  class LilrpgApp.HeroInventory extends App.Entities.Model
    urlRoot: -> Routes.hero_inventory_index_path()

    initialize: ->
      console.log "this should have these params", @

  class LilrpgApp.HeroInventoryCollection extends App.Entities.Collection
    model: LilrpgApp.HeroInventory
    url: -> Routes.hero_inventory_index_path()

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

    getHeroInventoryCollection: ->
      lilrpgs = new LilrpgApp.HeroInventoryCollection
      lilrpgs.fetch
        reset: true
      lilrpgs
    getHeroInventory: (id) ->
      lilrpg = new LilrpgApp.HeroInventory
        id: id
      lilrpg.fetch()
      lilrpg
    newHeroInventory: ->
      new LilrpgApp.HeroInventory

  App.reqres.setHandler 'hero:items:entities', ->
    API.getHeroItemsCollection()

  App.reqres.setHandler 'hero:items:entity', (id) ->
    API.getHeroItems id

  App.reqres.setHandler 'new:hero:items:entity', ->
    API.newHeroItems()

  App.reqres.setHandler 'hero:inventory:entities', ->
    API.getHeroInventoryCollection()

  App.reqres.setHandler 'hero:inventory:entity', (id) ->
    API.getHeroInventory id

  App.reqres.setHandler 'new:hero:inventory:entity', ->
    API.newHeroInventory()
