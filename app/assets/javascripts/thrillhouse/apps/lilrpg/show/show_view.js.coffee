@Thrillhouse.module 'LilrpgApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Lilrpg extends App.Views.ItemView
    template: 'lilrpg/show/_lilrpg'

  class Show.Show extends App.Views.ItemView
    template: 'lilrpg/show/_show'

  class Show.Layout extends App.Views.Layout
    template: 'lilrpg/show/show_layout'
    regions:
      showRegion: '#show-region'