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

    show: (view) ->
      @listenTo view, 'destroy', @destroy
      @region.show view

    buildElementMoves: (moves, element) ->
      moveList = _.filter moves.models, (model) ->
        if model.get("element") is element
          return model
      return new Backbone.Collection moveList

    disableButtons: (element) ->
      value = $(element).text()
      $(element).html("<strike>#{value}</strike>")
      $(element).addClass('disabled')



