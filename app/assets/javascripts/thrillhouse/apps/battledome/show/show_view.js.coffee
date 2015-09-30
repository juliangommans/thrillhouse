@Thrillhouse.module 'BattledomeApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Battledome extends App.Views.ItemView
    template: 'battledome/show/_battledome'

  class Show.Ui extends App.Views.ItemView
    template: 'battledome/show/_ui'
    ui:
      playerMoves: '.player-moves'
      confirmChoices: '.player-confirm-moves'
      clearChoices: '.player-clear-moves'
      closeMoves: '#close-move-list'
      acceptMoves: '#accept-move-list'

    events:
      'mouseenter @ui.playerMoves': 'showData'
      'mouseleave @ui.playerMoves': 'hideData'
      'click @ui.playerMoves': "selected"
      'click @ui.acceptMoves': "reRender"

    triggers:
      'click @ui.clearChoices': "clear:chosen:moves"
      'click @ui.confirmChoices': "confirm:chosen:moves"
      'click @ui.closeMoves': "clear:chosen:moves"

    selected: (args) ->
      if $(args.currentTarget).hasClass('selected')
        @triggerMethod("unselect:this:move", args, @)
        $(args.currentTarget).removeClass('selected-last')
        $(args.currentTarget).removeClass('selected')
      else
        $(args.currentTarget).addClass('selected')
        $('.selected-last').removeClass('selected-last')
        $(args.currentTarget).addClass('selected-last')
        @triggerMethod("check:action:points", args, @)

    reRender: ->
      @render()

    onRender: ->
      @triggerMethod("reset:action:points")


  class Show.Layout extends App.Views.Layout
    template: 'battledome/show/battledome_layout'
    regions:
      panelRegion: "#panel-region"
      displayRegion: "#display-region"
      combatLogRegion: "#combat-log-region"
      uiRegion: "#ui-region"
