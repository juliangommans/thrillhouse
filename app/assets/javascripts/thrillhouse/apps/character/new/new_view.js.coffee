@Thrillhouse.module 'CharacterApp.New', (New, App, Backbone, Marionette, $, _) ->

  class New.Character extends App.Views.ItemView
    template: 'character/new/character'