@Thrillhouse.module 'CharacterApp.List', (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @characters = App.request "character:entities"

      App.execute "when:fetched", @characters, =>
        @layout = @getLayout()

        @listenTo @layout, "show", =>
          @listView @characters

        @show @layout

    listView: (characters) ->
      console.log characters
      listView = @getListView characters

      @listenTo listView, "childview:show:character", (child, args) ->
        App.request "character:show", args.model

      @layout.characterRegion.show listView


    getListView: (characters) ->
      new List.Characters
        collection: characters

    getLayout: ->
      new List.Layout

