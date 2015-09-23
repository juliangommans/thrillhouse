@Thrillhouse.module 'CharacterApp.List', (List, App, Backbone, Marionette, $, _) ->

  class List.Character extends App.Views.ItemView
    template: 'character/list/_character'
    tagName: 'tr'
    className: 'character'
    triggers:
      "click #name" : "show:character"

  class List.Layout extends App.Views.Layout
    template: 'character/list/list_layout'
    regions:
      titleRegion: "#title-region"
      characterRegion: "#character-region"

  class List.Characters extends App.Views.CompositeView
    template: 'character/list/_list'
    childView: List.Character
    childViewContainer: 'tbody'
