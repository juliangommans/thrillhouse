@Thrillhouse.module 'MoveApp.List', (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: 'move/list/list_layout'
    regions:
      elementsRegion: '#elements-region'
      waterRegion: '#water-region'
      fireRegion: '#fire-region'
      airRegion: '#air-region'
      movesRegion: '#moves-region'
      listRegion: '#list-region'

  class List.Moves extends App.Views.ItemView
    template: 'move/list/_moves'
    tagName: 'li'
    className: 'dropdown-submenu'
    triggers:
      "click a": "get:move:show"

  class List.MoveList extends App.Views.CompositeView
    template: 'move/list/_move_list'
    childView: List.Moves
    childViewContainer: 'ul'
    className: "dropdown-submenu"
