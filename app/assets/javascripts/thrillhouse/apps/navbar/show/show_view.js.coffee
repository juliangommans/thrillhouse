@Thrillhouse.module 'NavbarApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Navbar extends App.Views.ItemView
    template: 'navbar/show/navbar'
    triggers:
      'click #home': 'go:home'
      "click #character-list" : "get:character:list"
      "click #battle-dome" : "get:battle:dome"
      "click #move-list" : "get:move:list"
      "click #lil-cric" : "get:lil:cric"
      "click #lil-rpg" : "get:lil:rpg"
      "click #lil-rpg-map" : "get:lil:rpg:map"
