@Thrillhouse.module 'HomeApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Home extends App.Views.ItemView
    template: 'home/show/_links'
    triggers:
      "click #character-list" : "get:character:list"
      "click #battle-dome" : "get:battle:dome"
      "click #move-list" : "get:move:list"
      "click #lil-cric" : "get:lil:cric"
      "click #lil-rpg" : "get:lil:rpg"
      "click #lil-rpg-map" : "get:lil:rpg:map"

  class Show.Panel extends App.Views.ItemView
    template: 'home/show/_panel'

  class Show.Layout extends App.Views.Layout
    template: 'home/show/show_layout'
    regions:
      panelRegion: "#panel-region"
      listRegion: "#list-region"
