@Thrillhouse.module 'CharacterApp', (CharacterApp, App, Backbone, Marionette, $, _) ->

  class CharacterApp.Router extends Marionette.AppRouter
    appRoutes:
      'character/:id' : 'show'
      'character': 'list'

  API =
    show: (id, character) ->
      new CharacterApp.Show.Controller
        id: id
        character: character

    list: ->
      new CharacterApp.List.Controller

  App.reqres.setHandler "character:list", ->
    App.navigate Routes.character_index_path()
    API.list()

  App.reqres.setHandler "character:show", (character) ->
    App.navigate Routes.character_path(character.id)
    API.show character.id, character

  App.addInitializer ->
    new CharacterApp.Router
      controller: API
