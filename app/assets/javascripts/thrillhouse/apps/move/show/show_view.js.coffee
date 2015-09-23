@Thrillhouse.module 'MoveApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Move extends App.Views.ItemView
    template: 'move/show/_move'

  class Show.Description extends App.Views.ItemView
    template: 'move/show/_description'

  class Show.Layout extends App.Views.Layout
    template: 'move/show/show_layout'
    regions:
      showRegion: '#show-region'
      descriptionRegion: '#description-region'
