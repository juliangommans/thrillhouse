@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->

  class LilrpgApp.Lilrpg extends App.Entities.Model
    urlRoot: -> Routes.lilrpg_index_path()

  class LilrpgApp.LilrpgCollection extends App.Entities.Collection
    model: LilrpgApp.Lilrpg
    url: -> Routes.lilrpg_index_path()

  class LilrpgApp.Controls extends App.Entities.Model

    defaults:
      32:
        key: "space"
        action: "block"
        axisChange: 0
        spaces: 0
        code: 32
      37:
        key: "left"
        action: "move"
        axisChange: -1
        spaces: 1
        code: 37
      38:
        key: "up"
        action: "move"
        axisChange: -1
        spaces: 1
        code: 38
      39:
        key: "right"
        action: "move"
        axisChange: 1
        spaces: 1
        code: 39
      40:
        key: "down"
        action: "move"
        axisChange: 1
        spaces: 1
        code: 40
      81:
        key: "Q"
        action: "spell"
        axisChange: 0
        spaces: 3
        code: 81
      87:
        key: "W"
        action: "spell"
        axisChange: 0
        spaces: 1
        code: 87
      69:
        key: "E"
        action: "spell"
        axisChange: 0
        spaces: 3
        code: 69
      65:
        key: "A"
        action: "attack"
        axisChange: 0
        spaces: 1
        code: 65
      83:
        key: "S"
        action: "spell"
        axisChange: 0
        spaces: 3
        code: 83
      68:
        key: "D"
        action: "block"
        axisChange: 0
        spaces: 0
        code: 68

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
    controls: ->
      new LilrpgApp.Controls

  App.reqres.setHandler "lilrpg:player:controls", ->
    API.controls()

  App.reqres.setHandler 'lilrpg:entities', ->
    API.getLilrpgs()

  App.reqres.setHandler 'lilrpg:entity', (id) ->
    API.getLilrpg id

  App.reqres.setHandler 'new:lilrpg:entity', ->
    API.newLilrpg()
