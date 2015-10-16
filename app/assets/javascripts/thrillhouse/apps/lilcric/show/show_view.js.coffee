@Thrillhouse.module 'LilcricApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Lilcric extends App.Views.ItemView
    template: 'lilcric/show/_lilcric'

  class Show.Controls extends App.Views.ItemView
    template: 'lilcric/show/controls'
    ui:
      bowl: "#js-bowl"
    triggers:
      'click @ui.bowl': 'bowl:the:ball'

  class Show.Layout extends App.Views.Layout
    template: 'lilcric/show/show_layout'
    regions:
      playRegion: '#play-region'
      bottomRegion: '#bottom-region'
      controlRegion: '#control-region'
