@Thrillhouse.module 'LilcricApp.Score', (Score, App, Backbone, Marionette, $, _) ->

  class Score.Controller extends App.Controllers.Base

    initialize: (options) ->
      console.log "options", options
      if options.table is "ball"
        @view = @getRunsView(options.collection)
      else if options.table is "overs"
        @view = @getOversView(options.collection)
      else
        alert "mate, you picked the wrong table (LilcricApp/score)", options
      @view

    getRunsView: (collection) ->
      new Score.Runs
        collection: collection

    getOversView: (collection) ->
      console.log "we're in the overs VIEW"
      new Score.Overs
        collection: collection
