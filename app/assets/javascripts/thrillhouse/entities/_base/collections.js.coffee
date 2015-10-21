@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Collection extends Backbone.Collection

    getTotal: (identifier) ->
      total = 0
      for item in @.models
        if typeof item.get(identifier) is "number"
          total += item.get(identifier)
        else
          console.log "wtf is this?", item.get(identifier)
      total
