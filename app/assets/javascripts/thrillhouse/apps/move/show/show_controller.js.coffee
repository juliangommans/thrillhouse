@Thrillhouse.module 'MoveApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options) ->
      { move, id } = options
      console.log options
      move or= App.request "move:entity", id
      App.execute "when:fetched", move, =>
        @layout = @getLayout()

        @listenTo @layout, 'show', =>
          @showView move
          @descriptionView move
        @show @layout

    descriptionView: (move) ->
      descriptionView = @getDescriptionView move
      @layout.descriptionRegion.show descriptionView

    showView: (move) ->
      showView = @getShowView move
      @layout.showRegion.show showView

    getDescriptionView: (move) ->
      new Show.Description
        model: move

    getShowView: (move) ->
      new Show.Move
        model: move

    getLayout: ->
      new Show.Layout
