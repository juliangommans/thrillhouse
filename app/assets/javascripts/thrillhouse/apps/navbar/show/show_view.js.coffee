@Thrillhouse.module 'NavbarApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Navbar extends App.Views.ItemView
    template: 'navbar/show/navbar'
    triggers:
      'click #home': 'go:home'
      'click #chars': 'get:character:list'
      'click #moves': 'get:move:list'
