@Thrillhouse.module 'LilcricApp.Results', (Results, App, Backbone, Marionette, $, _) ->

  class Results.Lilcric extends App.Views.ItemView
    template: 'lilcric/results/_lilcric'

  class Results.Results extends App.Views.ItemView
    template: 'lilcric/results/_results'

  class Results.Layout extends App.Views.Layout
    template: 'lilcric/results/results_layout'
    regions:
      resultsRegion: '#results-region'