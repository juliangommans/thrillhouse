@Thrillhouse.module 'LilrpgApp.Heroinfo', (Heroinfo, App, Backbone, Marionette, $, _) ->

  class Heroinfo.Controller extends App.Controllers.Base

    initialize: (options) ->
      { @hero } = options.hero
      @updateItems()
      @updateSpells()

    updateItems: ->

    updateSpells: ->


    #   @layout = @getLayout()
    #   @listenTo @layout, 'show', =>
    #     @heroinfoView()
    #   @show @layout

    # getLayout: ->
    #   new Heroinfo.Layout

    # heroinfoView: ->
    #   heroinfoView = @getHeroinfoView()
    #   @layout.heroinfoRegion.show heroinfoView

    # getHeroinfoView: ->
    #   new Heroinfo.Lilrpg
