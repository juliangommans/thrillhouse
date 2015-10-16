@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Lilcric extends App.Entities.Model
    urlRoot: -> Routes.lilcric_index_path()

  class Entities.LilcricCollection extends App.Entities.Collection
    model: Entities.Lilcric
    url: -> Routes.lilcric_index_path()

  API =
    getLilcrics: ->
      lilcrics = new Entities.LilcricCollection
      lilcrics.fetch
        reset: true
      lilcrics
    getLilcric: (id) ->
      lilcric = new Entities.Lilcric
        id: id
      lilcric.fetch()
      lilcric
    newLilcric: ->
      new Entities.Lilcric

  App.reqres.setHandler 'lilcric:entities', ->
    API.getLilcrics()

  App.reqres.setHandler 'lilcric:entity', (id) ->
    API.getLilcric id

  App.reqres.setHandler 'new:lilcric:entity', ->
    API.newLilcric()