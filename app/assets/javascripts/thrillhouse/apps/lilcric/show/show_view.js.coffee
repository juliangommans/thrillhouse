@Thrillhouse.module 'LilcricApp.Show', (Show, App, Backbone, Marionette, $, _) =>

  class Show.Lilcric extends App.Views.ItemView
    template: 'lilcric/show/_lilcric'

    onRender: ->
      $(document).keydown (e) =>
        e.preventDefault()
        @trigger "batter:action"

  class Show.Controls extends App.Views.ItemView
    template: 'lilcric/show/controls'
    ui:
      ball: "#js-one-bowl"
      over: "#js-one-over"
      reset: "#js-reset"
      options: "#js-options"
      close: "#close-modal"
    events:
      'change @ui.options': "reporting"
    triggers:
      'click @ui.ball': 'bowl:one:ball'
      'click @ui.over': 'bowl:one:over'
      'click @ui.reset': 'reset:game'
      'click @ui.close': 'hide:modal'

    reporting: (args, view) ->
      @triggerMethod("reporting:options", args.currentTarget.selectedIndex)

  class Show.Layout extends App.Views.Layout
    template: 'lilcric/show/show_layout'
    regions:
      playRegion: '#play-region'
      bottomRegion: '#bottom-region'
      ballRegion: '#ball-region'
      overRegion: '#over-region'
      controlRegion: '#control-region'

