@Thrillhouse.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Lilcric extends App.Controllers.Base

    initialize: ->
      @keycodes =
        32: "block"
        37: "pull"
        38: "hook"
        39: "cut"
        40: "drive"
      @speeds =
        110: "slow"
        130: "medium"
        150: "fast"
        animateBefore: 0
        animateAfter: 0
        pick: 0
      @goodPitch =
        type: "good"
        bounce: -75
      @shortPitch =
        type: "short"
        bounce: -25
      @fullPitch =
        type: "full"
        bounce: -125


  API =
    lilcricData: ->
      new Entities.Lilcric

  App.reqres.setHandler 'get:lilcric:data', ->
    API.lilcricData()
