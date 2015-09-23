@Thrillhouse.module 'CharacterApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options) ->
      { character, id } = options
      character or= App.request "character:entity", id

      App.execute "when:fetched", character, =>

        @layout = @getLayout character
        @listenTo @layout, "show", =>

          @baseStatsView character
          @secondaryStatsView character
          @showView character

        @show @layout

    showView: (character) ->
      showView = @getShowView character
      @layout.detailsRegion.show showView

    secondaryStatsView: (character) ->
      secondaryStatsView = @getSecondaryStatsView character
      @layout.secondaryRegion.show secondaryStatsView

    baseStatsView: (character) ->
      baseStatsView = @getBaseStatsView character
      @layout.baseRegion.show baseStatsView

    getBaseStatsView: (character) ->
      new Show.BaseStats
        model: character

    getSecondaryStatsView: (character) ->
      new Show.SecondaryStats
        model: character

    getShowView: (character) ->
      new Show.Character
        model: character

    getLayout: (character) ->
      new Show.Layout
        model: character

