@Thrillhouse.module 'LilcricApp.Results', (Results, App, Backbone, Marionette, $, _) ->

  class Results.Controller extends App.Controllers.Base

    initialize: (options) ->
      console.log "OPTIONS", options
      @results = @getResult()
      @results.speed = options.speed.pick
      @results

    getResult: ->
      @getPitch(@options.pitch)

    getPitch: (type) ->
      action = @options.action
      switch type
        when "short"
          @getShortScore(action)
        when "good"
          @getGoodScore(action)
        when "full"
          @getFullScore(action)
        else
          alert "you broke all of the things"

    getShortScore: (action) ->
      switch action
        when "pull"
          {runs: 4, wicket: false, comment: "", action: action}
        when "cut"
          {runs: 2, wicket: false, comment: "", action: action}
        when "hook"
          {runs: 6, wicket: false, comment: "", action: action}
        when "drive"
          {runs: 0, wicket: true, comment: "were caught in the slips", action: action}
        when "block"
          {runs: 0, wicket: false, comment: "copped one right between the eyes", action: action}

    getGoodScore: (action) ->
      switch action
        when "pull"
          {runs: 2, wicket: true, comment: "skied the ball up in the air to get caught.", action: action}
        when "cut"
          {runs: 4, wicket: false, comment: "", action: action}
        when "hook"
          {runs: 0, wicket: false, comment: "swing and miss, taking a hit to the body.", action: action}
        when "drive"
          {runs: 4, wicket: false, comment: "", action: action}
        when "block"
          {runs: 1, wicket: false, comment: "", action: action}

    getFullScore: (action) ->
      switch action
        when "pull"
          {runs: 4, wicket: false, comment: "flick down to fine leg for 4", action: action}
        when "cut"
          {runs: 2, wicket: false, comment: "squeeze it away between point and third man for a comfortable 2", action: action}
        when "hook"
          {runs: 0, wicket: true, comment: "were clean bowled, wild swing at a yorker.", action: action}
        when "drive"
          {runs: 6, wicket: false, comment: "smash it back over the bowlers head", action: action}
        when "block"
          {runs: 0, wicket: false, comment: "get a clean block, no runs though", action: action}

    #   @layout = @getLayout()
    #   @listenTo @layout, 'show', =>
    #     @resultsView()
    #   @show @layout

    # getLayout: ->
    #   new Results.Layout

    # resultsView: ->
    #   resultsView = @getResultsView()
    #   @layout.resultsRegion.show resultsView

    # getResultsView: ->
    #   new Results.Lilcric
