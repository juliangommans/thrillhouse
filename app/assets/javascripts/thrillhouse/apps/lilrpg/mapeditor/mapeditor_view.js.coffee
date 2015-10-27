@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.Sidebar extends App.Views.ItemView
    template: 'lilrpg/mapeditor/sidebar'

  class Mapeditor.Mapeditor extends App.Views.ItemView
    template: 'lilrpg/mapeditor/mapeditor'

  class Mapeditor.Header extends App.Views.ItemView
    template: 'lilrpg/mapeditor/header'
    ui:
      options: "#js-options"
      close: "#close-modal"
    events:
      'change @ui.options': "mapOptions"
    triggers:
      'click @ui.close': "hide:modal"

   mapOptions: (args, view) ->
      @triggerMethod("map:options", args.currentTarget.selectedIndex)

  class Mapeditor.Layout extends App.Views.Layout
    template: 'lilrpg/mapeditor/mapeditor_layout'
    regions:
      mapRegion: '#map-region'
      mapHeaderRegion: '#map-header-region'
      mapSidebarRegion: '#map-sidebar-region'
      mapFooterRegion: '#map-footer-region'
