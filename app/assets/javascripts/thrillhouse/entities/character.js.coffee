@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Character extends App.Entities.Model
    urlRoot: -> Routes.character_index_path()

  class Entities.CharacterCollection extends App.Entities.Collection
    model: Entities.Character
    url: -> Routes.character_index_path()

  API =
    getCharacter: (id) ->
      character = new Entities.Character
        id: id
      character.fetch()
      character

    getCharacterList: ->
      characters = new Entities.CharacterCollection
      characters.fetch
        reset: true
      characters

  App.reqres.setHandler "character:entities", ->
    API.getCharacterList()

  App.reqres.setHandler "character:entity", (id) ->
    API.getCharacter id
