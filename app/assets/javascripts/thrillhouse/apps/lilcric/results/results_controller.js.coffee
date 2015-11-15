@Thrillhouse.module 'LilcricApp.Results', (Results, App, Backbone, Marionette, $, _) ->

  class Results.Controller extends App.Controllers.Base

    initialize: (options) ->
      kph = options.speed.pick
      @speed = options.speed[kph]
      @results = @getResult()
      @results.action = @options.action
      @results.pitch = @options.pitch
      @results.speed = kph
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
          switch @speed
            when "slow"
              {runs: 6, wicket: false, comment: ""}
            when "medium"
              {runs: 4, wicket: false, comment: ""}
            when "fast"
              {runs: 1, wicket: true, comment: "get a massive top edge, caught in from the rope at fine leg"}
        when "cut"
          switch @speed
            when "slow"
              {runs: 1, wicket: true, comment: "swung too early through the slow ball and skied it into points mittens"}
            when "medium"
              {runs: 4, wicket: false, comment: ""}
            when "fast"
              {runs: 6, wicket: false, comment: ""}
        when "hook"
          switch @speed
            when "slow"
              {runs: 6, wicket: false, comment: ""}
            when "medium"
              {runs: 1, wicket: false, comment: ""}
            when "fast"
              {runs: 6, wicket: false, comment: ""}
        when "drive"
          switch @speed
            when "slow"
              {runs: 0, wicket: false, comment: ""}
            when "medium"
              {runs: 4, wicket: false, comment: ""}
            when "fast"
              {runs: 0, wicket: true, comment: "were caught in the slips after getting a healthy edge"}
        when "block"
          switch @speed
            when "slow"
              {runs: 0, wicket: false, comment: ""}
            when "medium"
              {runs: 1, wicket: false, comment: "got a thick outside edge, get a sneaky single"}
            when "fast"
              {runs: 0, wicket: false, comment: "copped one right between the eyes"}

    getGoodScore: (action) ->
      switch action
        when "pull"
          switch @speed
            when "slow"
              {runs: 6, wicket: false, comment: ""}
            when "medium"
              {runs: 3, wicket: false, comment: ""}
            when "fast"
              {runs: 2, wicket: true, comment: "did however ski the ball up in the air and got caught on the rope"}
        when "cut"
          switch @speed
            when "slow"
              {runs: 4, wicket: false, comment: ""}
            when "medium"
              {runs: 1, wicket: false, comment: ""}
            when "fast"
              {runs: 4, wicket: false, comment: ""}
        when "hook"
          switch @speed
            when "slow"
              {runs: 0, wicket: true, comment: "didn't read the slow ball, big wiff at the air, clean bowled"}
            when "medium"
              {runs: 4, wicket: false, comment: ""}
            when "fast"
              {runs: 0, wicket: false, comment: "swing and miss, taking a hit to the body"}
        when "drive"
          switch @speed
            when "slow"
              {runs: 2, wicket: false, comment: ""}
            when "medium"
              {runs: 0, wicket: true, comment: "were caught and bowled from a soft push"}
            when "fast"
              {runs: 4, wicket: false, comment: "split mid on and off perfectly"}
        when "block"
          switch @speed
            when "slow"
              {runs: 0, wicket: false, comment: ""}
            when "medium"
              {runs: 1, wicket: false, comment: ""}
            when "fast"
              {runs: 0, wicket: false, comment: ""}

    getFullScore: (action) ->
      switch action
        when "pull"
          switch @speed
            when "slow"
              {runs: 2, wicket: false, comment: ""}
            when "medium"
              {runs: 0, wicket: false, comment: ""}
            when "fast"
              {runs: 4, wicket: false, comment: "flick it down to fine leg for 4"}
        when "cut"
          switch @speed
            when "slow"
              {runs: 4, wicket: false, comment: "wait on the ball and play beautifully off the back foot"}
            when "medium"
              {runs: 2, wicket: false, comment: "squeeze it away between point and third man for a comfortable 2"}
            when "fast"
              {runs: 0, wicket: true, comment: "get a tickle and the keeper gloves it for an easy catch"}
        when "hook"
          switch @speed
            when "slow"
              {runs: 6, wicket: false, comment: "charge a slow full one and park it comfortably in the stands"}
            when "medium"
              {runs: 0, wicket: false, comment: "get a wild swing and a miss"}
            when "fast"
              {runs: 0, wicket: true, comment: "were clean bowled, taking a wild swing at a yorker"}
        when "drive"
          switch @speed
            when "slow"
              {runs: 3, wicket: false, comment: "smack it past the bowler who reigns it in from the rope"}
            when "medium"
              {runs: 4, wicket: false, comment: "smash it back over the bowlers head for 1 bounce"}
            when "fast"
              {runs: 6, wicket: false, comment: "smash it back over the bowlers head for a glorious maximum"}
        when "block"
          switch @speed
            when "slow"
              {runs: 0, wicket: false, comment: "get a clean block, no runs though"}
            when "medium"
              {runs: 0, wicket: false, comment: "get a clean block, no runs though"}
            when "fast"
              {runs: 2, wicket: false, comment: "get a thick edge down to third man for a comfortable 2"}

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
