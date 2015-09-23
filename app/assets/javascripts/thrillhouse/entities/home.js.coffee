@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Home extends App.Entities.Model
    urlRoot: -> Routes.home_path()

  # class Entities.HomeCollection extends App.Entities.Collection
  #   model: Entities.Home
  #   url: -> Routes.home_//your_rails_path()//

  API =
    home: ->
      new Entities.Home

  App.reqres.setHandler "get:home", ->
    API.home()
