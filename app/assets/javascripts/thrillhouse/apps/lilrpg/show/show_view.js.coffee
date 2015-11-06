@Thrillhouse.module 'LilrpgApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.PlayerHealth extends App.Views.ItemView
    template: 'lilrpg/show/player_health'

  class Show.Inventory extends App.Views.ItemView
    template: 'lilrpg/show/inventory'

  class Show.Spell extends App.Views.ItemView
    template: 'lilrpg/show/spell'

  class Show.Spells extends App.Views.CompositeView
    template: 'lilrpg/show/spells'
    childView: Show.Spell
    childViewContainer: '#spells-collection'

  class Show.Dialog extends App.Views.ItemView
    template: 'lilrpg/show/dialog'
    ui:
      loadMap: "#load-modal"
    triggers:
      'click @ui.loadMap': 'load:selected:map'

  class Show.LoadMap extends App.Views.ItemView
    template: 'lilrpg/show/load_map'
    tagName: "option"

  class Show.LoadMaps extends App.Views.CompositeView
    template: 'lilrpg/show/load_maps'
    childView: Show.LoadMap
    childViewContainer: "#load-select"
    events:
      'change #load-select': "getId"

    getId: (e) ->
      e.preventDefault
      target = e.currentTarget[e.currentTarget.selectedIndex]
      id = $($(target).children()).data("id")
      @trigger "load:selected:map", id

  class Show.Show extends App.Views.ItemView
    template: 'lilrpg/show/_show'

    onRender: ->
      $(document).keydown (e) =>
        e.preventDefault()
        @trigger "player:action"

  class Show.Layout extends App.Views.Layout
    template: 'lilrpg/show/show_layout'
    regions:
      healthRegion: '#player-health'
      invRegion: '#inventory-region'
      lilrpgPlayRegion: '#lilrpg-play-region'
      dialogRegion: '#dialog-region'
