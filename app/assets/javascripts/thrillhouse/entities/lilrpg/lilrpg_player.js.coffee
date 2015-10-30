@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Player extends App.Entities.Model

    move: (options) ->
      location = @get('location')
      { key, direction, spaces } = options
      if key is "up" or key is "down"
        if location.length > 2
          direction * 10
      if spaces > 1
        direction * spaces
      location = location + direction
      console.log "location", location
      @set location: location

  class LilrpgApp.Controls extends App.Entities.Model

    initialize: ->
      @set(@controls())

    controls: ->
      32:
        key: "space"
        action: "block"
        direction: 0
        spaces: 0
        code: 32
      37:
        key: "left"
        action: "move"
        direction: -1
        spaces: 1
        code: 37
      38:
        key: "up"
        action: "move"
        direction: -10
        spaces: 1
        code: 38
      39:
        key: "right"
        action: "move"
        direction: +1
        spaces: 1
        code: 39
      40:
        key: "down"
        action: "move"
        direction: +10
        spaces: 1
        code: 40
      81:
        key: "Q"
        action: "spell"
        direction: 0
        spaces: 1
        code: 81
      87:
        key: "W"
        action: "spell"
        direction: 0
        spaces: 1
        code: 87
      82:
        key: "R"
        action: "spell"
        direction: 0
        spaces: 82
      65:
        key: "A"
        action: "attack"
        direction: 0
        spaces: 1
        code: 65
      83:
        key: "S"
        action: "attack"
        direction: 0
        spaces: 3
        code: 83
      68:
        key: "D"
        action: "block"
        direction: 0
        spaces: 0
        code: 68

  API =
    player: ->
      new LilrpgApp.Player
    controls: ->
      new LilrpgApp.Controls

  App.reqres.setHandler "lilrpg:player:controls", ->
    API.controls()

  App.reqres.setHandler "lilrpg:player:entity", ->
    API.player()


