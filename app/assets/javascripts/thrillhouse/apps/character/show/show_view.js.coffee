@Thrillhouse.module 'CharacterApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.BaseStats extends App.Views.ItemView
    template: 'character/show/_base_stats'

  class Show.SecondaryStats extends App.Views.ItemView
    template: 'character/show/_secondary_stats'

  class Show.Character extends App.Views.ItemView
    template: 'character/show/_character'

  class Show.Layout extends App.Views.Layout
    template: 'character/show/show_layout'
    regions:
      titleRegion: "#title-region"
      detailsRegion: "#details-region"
      baseRegion: "#base-stats-region"
      secondaryRegion: "#secondary-stats-region"
