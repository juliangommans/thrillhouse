@Thrillhouse.module 'CharacterApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->

  class Edit.Character extends App.Views.ItemView
    template: 'character/edit/character'