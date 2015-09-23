@Thrillhouse.module 'CharacterApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->

  class Edit.Controller extends App.Controllers.Base

    initialize: ->
      editView = @getEditView()
      @show editView

    getEditView: ->
      new Edit.Character