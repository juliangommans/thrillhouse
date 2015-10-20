@Thrillhouse.module 'LilcricApp.Score', (Score, App, Backbone, Marionette, $, _) ->

  class Score.over extends App.Views.ItemView
    template: 'lilcric/score/_over'

  class Score.Run extends App.Views.ItemView
    template: 'lilcric/score/_run'
    tagName: "td"
    className: "run-row"
    onRender: ->
      shots = new Score.Shot
        model: @model
      shots.render()
      @$el.append(shots.el)

  class Score.Shot extends App.Views.ItemView
    template: 'lilcric/score/_shot'
    tagName: "td"
    onRender: ->
      console.log "this is the errrvrything", @
      wickets = new Score.Wicket
        model: @model
      wickets.render()
      @$el.append(wickets.el)

  class Score.Wicket extends App.Views.ItemView
    template: 'lilcric/score/_wicket'
    tagName: "td"

  class Score.Runs extends App.Views.CompositeView
    template: 'lilcric/score/runs_layout' #'lilcric/score/runs'
    childView: Score.Run
    childViewContainer: "#score-region"

  # class Score.Shots extends App.Views.CompositeView
  #   template: 'lilcric/score/shots'
  #   childView: Score.Shot
  #   childViewContainer: "#shots-region"

  # class Score.Wickets extends App.Views.CompositeView
  #   template: 'lilcric/score/wickets'
  #   childView: Score.Wicket
  #   childViewContainer: "#wickets-region"

  # class Score.RunsLayout extends App.Views.Layout
  #   template: 'lilcric/score/runs_layout'
  #   regions:
  #     runRegion: "#runs-region"
  #     shotRegion: "#shots-region"
  #     wicketRegion: "#wickets-region"
  #     speedRegion: "#speeds-region"

  class Score.Overs extends App.Views.CompositeView
    template: 'lilcric/score/overs_layout'
