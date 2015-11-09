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
      $(".#{spell}").stop()
      $(".#{spell}").remove()

    checkIllegalMoves: (newCoords) ->
      illegalMoves = ['wall', 'enemy', 'player']
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
