@Thrillhouse.module 'LilcricApp.Score', (Score, App, Backbone, Marionette, $, _) ->

  class Score.Controller extends App.Controllers.Base

    initialize: (options) ->
      @view = @getRunsView(options.collection)
      # @collection = options.collection
      # @listenTo @view, "show", =>
      #   @showRuns()
      #   @showShots()
      #   @showWickets()

      @view

    # showRuns: ->
    #   @runs = @collection.filter( (model) ->
    #     model.get('runs')
    #   )
    #   runsView = @getRunsView()
    #   @view.runRegion.show runsView

    # showWickets: ->
    #   @wickets = @collection.filter( (model) ->
    #     model.get('wicket')
    #   )
    #   wicketsView = @getWicketsView()

    #   @view.wicketRegion.show wicketsView

    # showShots: ->
    #   @shots = @collection.filter( (model) ->
    #     model.get('action')
    #   )
    #   shotsView = @getShotsView()

    #   @view.shotRegion.show shotsView

    getRunsView: (collection) ->
      new Score.Runs
        collection: collection #@runs

    # getWicketsView: ->
    #   new Score.Wickets
    #     collection: @wickets

    # getShotsView: ->
    #   new Score.Shots
    #     collection: @shots

    # getRunsLayout: ->
    #   new Score.RunsLayout


