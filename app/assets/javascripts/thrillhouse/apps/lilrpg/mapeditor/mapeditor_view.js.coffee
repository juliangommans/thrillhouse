@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.SidebarType extends App.Views.ItemView
    template: 'lilrpg/mapeditor/_sidebar'
    tagname: "li"
    className: "list-group-item"
    events:
      'click': 'selected'

    selected: (args) ->
      if $(args.currentTarget).hasClass('selected')
        $(args.currentTarget).removeClass('selected')
      else
        $('.selected').removeClass('selected')
        $(args.currentTarget).addClass('selected')

  class Mapeditor.Sidebar extends App.Views.CompositeView
    template: 'lilrpg/mapeditor/sidebar'
    childView: Mapeditor.SidebarType
    childViewContainer: "#insertables"

  class Mapeditor.Show extends App.Views.ItemView
    template: 'lilrpg/mapeditor/mapeditor'
    ui:
      cell: '.map-cell'
    events:
      'click @ui.cell': "selectedCell"

    selectedCell: (args) ->
      selectedObject = $($('.selected div')[1]).attr("class")
      clone = $($('.selected div')[1]).clone()
      @trigger "place:selected:object", args, selectedObject, clone

  class Mapeditor.Header extends App.Views.ItemView
    template: 'lilrpg/mapeditor/header'
    ui:
      options: "#js-map-options"
      close: "#close-modal"
    events:
      'change @ui.options': "mapOptions"
    triggers:
      'click @ui.close': "hide:modal"

    mapOptions: (args, view) ->
      @triggerMethod("map:options", args.currentTarget.value)

  class Mapeditor.Layout extends App.Views.Layout
    template: 'lilrpg/mapeditor/mapeditor_layout'
    regions:
      mapRegion: '#map-region'
      mapHeaderRegion: '#map-header-region'
      mapSidebarRegion: '#map-sidebar-region'
      mapFooterRegion: '#map-footer-region'
