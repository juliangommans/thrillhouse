@Thrillhouse.module 'CharacterApp.New', (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: ->
      newView = @getNewView()
      @show newView

    getNewView: ->
      new New.Character