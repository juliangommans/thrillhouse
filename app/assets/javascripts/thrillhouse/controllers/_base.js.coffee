@Thrillhouse.module 'Controllers', (Controllers, App, Backbone, Marionette, $, _) ->

  class Controllers.Base extends Marionette.Controller

    constructor: (options = {}) ->
      @region = options.region or App.request 'default:region'
      super options
      @_instance_id = _.uniqueId('controllers')
      App.execute 'register:instance', @, @_instance_id

    destroy: (args...) ->
      delete @region
      delete @options
      super args
      App.execute 'unregister:instance', @, @_instance_id

    show: (view, options = {}) ->
      _.defaults options,
        loading: false
        region: @region

      @_setMainView view
      @_manageView view, options

    _setMainView: (view) ->
      ## the first view we show is always going to become the mainView of our
      ## controller (whether its a layout or another view type).  So if this
      ## *is* a layout, when we show other regions inside of that layout, we
      ## check for the existance of a mainView first, so our controller is only
      ## closed down when the original mainView is closed.

      return if @_mainView
      @_mainView = view
      @listenTo view, "destroy", @destroy

    _manageView: (view, options) ->
      if options.loading
        ## show the loading view
        App.execute "show:loading", view, options
      else
        options.region.show view

#### custom controller logic

    buildElementMoves: (moves, element) ->
      moveList = _.filter moves.models, (model) ->
        if model.get("element") is element
          return model
      return new Backbone.Collection moveList

    disableButtons: (element) ->
      value = $(element).text()
      $(element).html("<strike>#{value}</strike>")
      $(element).addClass('disabled')

    oppositeTarget: (target) ->
      if target is "player"
        return "opponent"
      else if target is "opponent"
        return "player"
      else
        console.log "target is neither player nor opponnent"

    getTargetObject: (target) ->
      if target is "player"
        return {
          target: @player
          opposite: @opponent
        }
      else
        return {
          target: @opponent
          opposite: @player
        }

    getOwnersTarget: (owner, target) ->
      if owner is "player"
        if target is "us"
          return "player"
        else if target is "them"
          return "opponent"
        else
          console.log "players target is unknown"
      else if owner is "opponent"
        if target is "us"
          return "opponent"
        else if target is "them"
          return "player"
        else
          console.log "opponents target is unknown"
      else
        console.log "owner is not known"

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

    getNewLocation: (a,b,c) ->
      y = (@getOffset(b[0]).top - @getOffset(a[0]).top - c)
      x = (@getOffset(b[0]).left - @getOffset(a[0]).left)
      {
        top: y
        left: x
      }

    countdown: (@fun, num) ->
      timer = =>
        $('.countdown').html("<span>#{num}</span>")
        if num--
          $('.countdown').css(
            color: "black"
            opacity: "1"
          )
          $('.countdown')
            .animate(
              fontSize: "200%"
              color: "red"
              ,
              250
            )
            .animate(
              fontSize: "100%"
              color: "green"
              ,
              250
            )
          setTimeout timer, 500
        else
          $('.countdown').empty()
          @fun()
      timer()

    getRandomNum: (min, max) ->
      Math.floor(Math.random() * (max - min + 1)) + min
