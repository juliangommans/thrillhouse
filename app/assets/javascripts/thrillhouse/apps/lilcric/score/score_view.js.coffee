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
      wickets = new Score.Wicket
        model: @model
      wickets.render()
      @$el.append(wickets.el)

  class Score.Wicket extends App.Views.ItemView
    template: 'lilcric/score/_wicket'
    tagName: "td"
    onRender: ->
      length = new Score.Length
        model: @model
      length.render()
      @$el.append(length.el)

  class Score.Length extends App.Views.ItemView
    template: 'lilcric/score/_length'
    tagName: "td"
    onRender: ->
      speeds = new Score.Speed
        model: @model
      speeds.render()
      @$el.append(speeds.el)

  class Score.Speed extends App.Views.ItemView
    template: 'lilcric/score/_speed'
    tagName: "td"

  class Score.Runs extends App.Views.CompositeView
    template: 'lilcric/score/runs_layout'
    childView: Score.Run
    childViewContainer: "#run-score-region"

  class Score.Over extends App.Views.ItemView
    template: 'lilcric/score/_over'
    tagName: "tr"

  class Score.Overs extends App.Views.CompositeView
    template: 'lilcric/score/overs_layout'
    childView: Score.Over
    childViewContainer: "#over-score-region"
