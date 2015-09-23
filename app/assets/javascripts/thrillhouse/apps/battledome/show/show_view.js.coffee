@Thrillhouse.module 'BattledomeApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Battledome extends App.Views.ItemView
    template: 'battledome/show/_battledome'

  class Show.Ui extends App.Views.ItemView
    template: 'battledome/show/_ui'

  class Show.Layout extends App.Views.Layout
    template: 'battledome/show/battledome_layout'
    regions:
      panelRegion: "#panel-region"
      displayRegion: "#display-region"
      uiRegion: "#ui-region"

  class Show.Moves extends App.Views.CompositeView
    template: 'battledome/show/_moves'
