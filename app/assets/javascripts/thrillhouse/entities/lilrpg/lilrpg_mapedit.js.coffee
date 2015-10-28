@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.MapObjects extends App.Controllers.Base
    initialize: ->
      @collection = new App.Entities.Collection
      @reset = @buildResetObject()
      @buildObjects()

    buildObjects: ->
      vWall = @buildVerticalWall()
      hWall = @buildHorizontalWall()

      ary = [vWall, hWall, @reset]
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

    buildResetObject: ->
      cell = new App.Entities.Model
        class1: "empty-cell"
        class2: ""
        class3: ""
        name: "Reset Cell"



  class LilrpgApp.MapEnemies extends App.Controllers.Base

  class LilrpgApp.MapItems extends App.Controllers.Base

  API =
    getMapObjects: ->
      new LilrpgApp.MapObjects
    getMapEnemies: ->
      new LilrpgApp.MapEnemies
    getMapItems: ->
      new LilrpgApp.MapObjects

  App.reqres.setHandler 'lilrpg:map:objects', ->
    API.getMapObjects()

  App.reqres.setHandler 'lilrpg:map:enemies', ->
    API.getMapEnemies()

  App.reqres.setHandler 'lilrpg:map:items', ->
    API.getMapItems()
