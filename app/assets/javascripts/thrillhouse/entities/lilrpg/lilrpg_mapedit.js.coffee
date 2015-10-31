@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.MapObjects extends App.Controllers.Base
    initialize: ->
      @collection = new App.Entities.Collection
      @buildObjects()

    buildObjects: ->
      ary = []
      ary.push(@buildVerticalWall())
      ary.push(@buildHorizontalWall())

      for obj in ary
        @collection.add obj

    buildVerticalWall: ->
      wall = new App.Entities.Model
        class1: "vertical-wall "
        class2: "wall"
        class3: ""
        name: "Vertical Wall"

    buildHorizontalWall: ->
      wall = new App.Entities.Model
        class1: "horizontal-wall "
        class2: "wall"
        class3: ""
        name: "Horizontal Wall"

  class LilrpgApp.MapCharacters extends App.Controllers.Base
    initialize: ->
      @collection = new App.Entities.Collection
      @buildObjects()

    buildObjects: ->
      ary = []
      ary.push(@buildSimpleMeleeEnemy())
      ary.push(@buildSimpleRangedEnemy())
      ary.push(@buildPlayer())

      for obj in ary
        @collection.add obj

    buildSimpleMeleeEnemy: ->
      enemy = new App.Entities.Model
        class1: "simple-melee "
        class2: "enemy "
        class3: "character"
        name: "Simple Melee Enemy"

    buildSimpleRangedEnemy: ->
      enemy = new App.Entities.Model
        class1: "simple-ranged "
        class2: "enemy "
        class3: "character"
        name: "Simple Ranged Enemy"

    buildPlayer: ->
      player = new App.Entities.Model
        class1: "player "
        class2: "character"
        class3: ""
        name: "Player (you)"

  class LilrpgApp.MapItems extends App.Controllers.Base
    initialize: ->
      @collection = new App.Entities.Collection
      @buildObjects()

    buildObjects: ->
      ary = []
      ary.push(@buildTreasureChest())

      for obj in ary
        @collection.add obj

    buildTreasureChest: ->
      treasure = new App.Entities.Model
        class1: "item "
        class2: "tresure-chest"
        class3: ""
        name: "Treasure Chest"

  class LilrpgApp.LilrpgMap extends App.Entities.Model
    urlRoot: -> Routes.lil_rpg_map_editor_index_path()

    initialize: ->
      if @get('coordinates')
        @set coordinates: JSON.parse(@get('coordinates'))

  class LilrpgApp.LilrpgMapCollection extends App.Entities.Collection
    model: LilrpgApp.LilrpgMap
    url: -> Routes.lil_rpg_map_editor_index_path()

  API =
    getMapObjects: ->
      new LilrpgApp.MapObjects
    getMapCharacters: ->
      new LilrpgApp.MapCharacters
    getMapItems: ->
      new LilrpgApp.MapItems
    getLilrpgMaps: ->
      lilrpgs = new LilrpgApp.LilrpgMapCollection
      lilrpgs.fetch
        reset: true
      lilrpgs
    getLilrpgMap: (id) ->
      lilrpg = new LilrpgApp.LilrpgMap
        id: id
      lilrpg.fetch()
      lilrpg
    newLilrpgMap: ->
      new LilrpgApp.LilrpgMap

  App.reqres.setHandler 'lilrpg:map:entities', ->
    API.getLilrpgMaps()

  App.reqres.setHandler 'lilrpg:map:entity', (id) ->
    API.getLilrpgMap id

  App.reqres.setHandler 'new:lilrpg:map:entity', ->
    API.newLilrpgMap()

  App.reqres.setHandler 'lilrpg:map:objects', ->
    API.getMapObjects()

  App.reqres.setHandler 'lilrpg:map:characters', ->
    API.getMapCharacters()

  App.reqres.setHandler 'lilrpg:map:items', ->
    API.getMapItems()
