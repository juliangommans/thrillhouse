@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.Sidebar extends App.Views.ItemView
    template: 'lilrpg/mapeditor/sidebar'

  class Mapeditor.Mapeditor extends App.Views.ItemView
    template: 'lilrpg/mapeditor/mapeditor'

  class Mapeditor.Layout extends App.Views.Layout
    template: 'lilrpg/mapeditor/mapeditor_layout'
    regions:
      mapRegion: '#map-region'
      mapHeaderRegion: '#map-header-region'
      mapSidebarRegion: '#map-sidebar-region'
      mapFooterRegion: '#map-footer-region'