@Thrillhouse.module 'BattledomeApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      sampler = [1,2,3]
      @layout = @getLayout()
      @opponent = App.request "character:entity", _.sample(sampler)

      App.execute "when:fetched", @opponent, =>
        @player = App.request "character:entity", _.sample(sampler)

        App.execute "when:fetched", @player, =>
          model = @createBattleModel(@player, @opponent)
          console.log "thi s is the battle model", model
          @listenTo @layout, "show", =>
            @showView model
            @uiView model
          @show @layout

    getLayout: ->
      new Show.Layout

    showView: (model) ->
      showView = @getShowView(model)
      @layout.displayRegion.show showView

    uiView: (model) ->
      uiView = @getUiView(model)
      @layout.uiRegion.show uiView

    createBattleModel: (player, opponent) ->
      new Backbone.Model
        player: player
        opponent: opponent

    getShowView: (model) ->
      new Show.Battledome
        model: model

    getUiView: (model) ->
      new Show.Ui
        model: model
