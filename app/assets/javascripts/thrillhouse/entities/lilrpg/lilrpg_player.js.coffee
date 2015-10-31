@Thrillhouse.module 'Entities.LilrpgApp', (LilrpgApp, App, Backbone, Marionette, $, _) ->
  class LilrpgApp.Player extends App.Entities.Model

    initialize: ->
      @illegalMoves = ['wall','character']

    move: (keypress,map) ->
      location = @get('location')
      console.log "does it?", $($("##{location}")[0].children[0]).hasAnyClass(@illegalMoves)
      direction = @get('direction')
      coords = map.get('coordinates')
      newCoords = "cell-"
      newDirection = "cell-"
      { key, axisChange, spaces } = keypress
      if coords[location]
        cell = coords[location]
        if key is "up" or key is "down"
          change = cell.x + (axisChange * spaces)
          newCoords += "#{(change).toString()}-#{(cell.y).toString()}"
          newDirection += "#{(change + axisChange).toString()}-#{(cell.y).toString()}"
        else if key is "left" or key is "right"
          change = cell.y + (axisChange * spaces)
          newCoords += "#{(cell.x).toString()}-#{(change).toString()}"
          newDirection += "#{(cell.x).toString()}-#{(change + axisChange).toString()}"
      else
        console.log "you're out of bounds", cell
      unless coords[newCoords]
        newCoords = location
        newDirection = direction
        console.log "you tried to move out of bounds", newCoords

      unless $($("##{location}")[0].children[0]).hasAnyClass(@illegalMoves)
        @set direction: newDirection
      @set location: newCoords

  class LilrpgApp.Controls extends App.Entities.Model

    initialize: ->
      @set(@controls())

    controls: ->
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
        axisChange: +1
        spaces: 1
        code: 39
      40:
        key: "down"
        action: "move"
        axisChange: +1
        spaces: 1
        code: 40
      81:
        key: "Q"
        action: "spell"
        axisChange: 0
        spaces: 1
        code: 81
      87:
        key: "W"
        action: "spell"
        axisChange: 0
        spaces: 1
        code: 87
      82:
        key: "R"
        action: "spell"
        axisChange: 0
        spaces: 82
      65:
        key: "A"
        action: "attack"
        axisChange: 0
        spaces: 1
        code: 65
      83:
        key: "S"
        action: "attack"
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
    player: ->
      new LilrpgApp.Player
    controls: ->
      new LilrpgApp.Controls

  App.reqres.setHandler "lilrpg:player:controls", ->
    API.controls()

  App.reqres.setHandler "lilrpg:player:entity", ->
    API.player()


