@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Lil_cric extends App.Entities.Model
    urlRoot: -> Routes.lil_cric_index_path()

  class Entities.Lil_cricCollection extends App.Entities.Collection
    model: Entities.Lil_cric
    url: -> Routes.lil_cric_index_path()

  API =
    getLil_crics: ->
      lil_crics = new Entities.Lil_cricCollection
      lil_crics.fetch
        reset: true
      lil_crics
    getLil_cric: (id) ->
      lil_cric = new Entities.Lil_cric
        id: id
      lil_cric.fetch()
      lil_cric
    newLil_cric: ->
      new Entities.Lil_cric

  App.reqres.setHandler 'lil_cric:entities', ->
    API.getLil_crics()

  App.reqres.setHandler 'lil_cric:entity', (id) ->
    API.getLil_cric id

  App.reqres.setHandler 'new:lil_cric:entity', ->
    API.newLil_cric()