@Thrillhouse.module 'LilrpgApp.Mapeditor', (Mapeditor, App, Backbone, Marionette, $, _) ->

  class Mapeditor.SidebarType extends App.Views.ItemView
    template: 'lilrpg/mapeditor/_sidebar'
    tagname: "li"
    className: "list-group-item"
    events:
      'click': 'selected'

  class Mapeditor.Sidebar extends App.Views.CompositeView
    template: 'lilrpg/mapeditor/sidebar'
    childView: Mapeditor.SidebarType
    childViewContainer: "#insertables"

  class Mapeditor.SidebarLayout extends App.Views.Layout
    template: 'lilrpg/mapeditor/sidebar_layout'
    regions:
      compositeRegion: "#map-sidebar-body"
    ui:
      nav: ".map-sidebar-nav"
    events:
      'click @ui.nav': "getNewSidebarCollection"

    getNewSidebarCollection: (event) ->
      @trigger "get:sidebar:collection", event.currentTarget.id
      @selected(event, "active")

  class Mapeditor.Ui extends App.Views.ItemView
    template: 'lilrpg/mapeditor/ui'
    ui:
      create: "#new-map"
      save: "#save-map"
      load: "#load-map"
      clear: "#clear-map"
      saveMap: "#save-modal"
      loadMap: "#load-modal"
      cancel: ".cancel-modal"
    events:
      'click @ui.create': "openNewModal"
      'click @ui.save': "openSaveModal"
      'click @ui.load': "openLoadModal"
    triggers:
      'click @ui.saveMap': 'save:current:map'
      'click @ui.loadMap': 'load:selected:map'
      'click @ui.clear': 'clear:current:map'

    openNewModal: ->
      $('#map-editor-size-modal').modal("show")
    openSaveModal: ->
      $('#save-map-modal').modal("show")
    openLoadModal: ->
      $('#load-map-modal-bloop').modal("show")


  class Mapeditor.Show extends App.Views.ItemView
    template: 'lilrpg/mapeditor/mapeditor'
    ui:
      cell: '.map-cell'
    events:
      'mousedown @ui.cell': "rightClick"
      'contextmenu @ui.cell': "returnFalse"

    onRender: ->
      $(document).unbind("keydown")

    rightClick: (event) ->
      event.preventDefault()
      if event.which is 3 or event.button is 2
        $(event.currentTarget).empty()
      else if event.which is 1 or event.button is 0
        clone = $($('.selected div')[1]).clone()
        @trigger "place:selected:object", event, clone

  class Mapeditor.Header extends App.Views.ItemView
    template: 'lilrpg/mapeditor/header'
    ui:
      options: "#js-map-options"
      close: "#close-size-modal"
    events:
      'change @ui.options': "mapOptions"
    triggers:
      'click @ui.close': "hide:modal"

    mapOptions: (args, view) ->
      @triggerMethod("map:options", args.currentTarget.value)

  class Mapeditor.LoadMap extends App.Views.ItemView
    template: 'lilrpg/mapeditor/load_map'
    tagName: "option"

  class Mapeditor.LoadMaps extends App.Views.CompositeView
    template: 'lilrpg/mapeditor/load_maps'
    childView: Mapeditor.LoadMap
    childViewContainer: "#load-select"
    events:
      'change #load-select': "getId"

    getId: (e) ->
      e.preventDefault
      target = e.currentTarget[e.currentTarget.selectedIndex]
      id = $($(target).children()).data("id")
      @trigger "load:selected:map", id

  class Mapeditor.Layout extends App.Views.Layout
    template: 'lilrpg/mapeditor/mapeditor_layout'
    regions:
      mapRegion: '#map-region'
      mapHeaderRegion: '#map-header-region'
      mapSidebarRegion: '#map-sidebar-region'
      mapUiRegion: '#map-ui-region'
