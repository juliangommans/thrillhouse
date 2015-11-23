@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Model extends Backbone.Model

    destroy: (options = {}) ->
      _.defaults options,
        wait: true

      @set _destroy: true
      super options

    isDestroyed: ->
      @get '_destroy'

    save: (data, options = {}) ->
      isNew = @isNew()

      _.defaults options,
        wait: true
        success: _.bind(@saveSuccess, @, isNew, options.collection)
        error: _.bind(@saveError, @)

      @unset '_errors'
      super data, options

    saveSuccess: (isNew, collection) ->
      if isNew
        collection.add @ if collection
        collection.trigger 'model:created', @ if collection
        @trigger 'created', @
      else
        collection ?= @collection
        collection.trigger 'model:updated', @ if collection
        @trigger 'updated', @

    saveError: (model, xhr, options) ->
      @set _errors: $.parseJSON(xhr.responseText)?.errors unless xhr.status is 500 or xhr.status is 404

  class Entities.LilrpgModel extends Entities.Model

    rotate: (object, rotateSpeed) ->
      object.css WebkitTransform: 'rotate(' + @degree + 'deg)'
      object.css '-moz-transform': 'rotate(' + @degree + 'deg)'
      @rotationTimer = setTimeout(( =>
        @degree += rotateSpeed
        @rotate(object, rotateSpeed)
      ), 1)

    getElementByLoc: (loc) ->
      $("##{@buildCellName(loc)}")

    buildCellName: (loc) ->
      "cell-#{loc.x}-#{loc.y}"

    cleanupSpellSprite: (spell) ->
      spellname = spell.get("className")
      $(".#{spellname}").stop()
      $(".#{spellname}").remove()

    createAoeCells: (cell,radius) ->
      cells = []
      for newCell in [
        {x:-1,y:-1},
        {x:-1,y:0},
        {x:-1,y:1},
        {x:0,y:-1},
        {x:0,y:1},
        {x:1,y:-1},
        {x:1,y:0},
        {x:1,y:1}
      ]
        cells.push {
          x: cell.x + (newCell.x*radius)
          y: cell.y + (newCell.y*radius)
        }
      cells

    checkIllegalMoves: (newCoords) ->
      illegalMoves = ['wall', 'enemy', 'player']
      if $("##{newCoords}")[0]?
        $($("##{newCoords}")[0].children[0]).hasAnyClass(illegalMoves).bool

    getLoc: (range) ->
      [{
        direction: "left"
        y: -range
        x: 0
        },{
        direction: "down"
        y: 0
        x: range
        },{
        direction: "up"
        y: 0
        x: -range
        },{
        direction: "right"
        y: range
        x: 0
      }]

    buildLocation: (currentLoc,newLoc) ->
      {
        x: (currentLoc.x + newLoc.x)
        y: (currentLoc.y + newLoc.y)
      }

    oppositeDirection: (direction) ->
      opposite = {
        up: "down"
        down: "up"
        right: "left"
        left: "right"
      }
      opposite[direction]

    getOffset: (element) ->
      top = 0
      left = 0
      loop
        top += element.offsetTop or 0
        left += element.offsetLeft or 0
        element = element.offsetParent
        unless element
          break
      {
        top: top
        left: left
      }

    uniqueArrayFilter: (array, selector) ->
      arr = {}
      i = 0
      len = array.length
      while i < len
        arr[array[i][selector]] = array[i]
        i++
      array = new Array
      for key of arr
        array.push arr[key]
      array
