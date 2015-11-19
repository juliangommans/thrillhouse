@Thrillhouse.module 'LilrpgApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.PlayerHealth extends App.Views.ItemView
    template: 'lilrpg/show/player_health'

  class Show.Inventory extends App.Views.ItemView
    template: 'lilrpg/show/inventory'

  class Show.InventoryDisplay extends App.Views.ItemView
    template: 'lilrpg/show/inventory_display'

  class Show.Spell extends App.Views.ItemView
    template: 'lilrpg/show/spell'

  class Show.Spells extends App.Views.CompositeView
    template: 'lilrpg/show/spells'
    childView: Show.Spell
    childViewContainer: '#spells-collection'

  class Show.Dialog extends App.Views.ItemView
    template: 'lilrpg/show/dialog'
    ui:
      itemSelect: ".inv-box"
      itemDrop: ".drop-box"
      saveHeroChanges: "#save-hero-changes-modal"
      heroCancel: "#cancel-hero-modal"
      loadMap: "#load-modal"
      collect: "#collect-loot-modal"
      cancel: ".cancel-modal"
    events:
      'mouseenter .inv-box': 'showData'
      'mouseleave .inv-box': 'hideData'
      'mouseenter .loot-box': 'showData'
      'mouseleave .loot-box': 'hideData'
      'click @ui.cancel': 'closeBackdrop'
      'click @ui.itemSelect': 'selectItem'
      'click @ui.itemDrop': 'dropSelectedItem'
    triggers:
      'click @ui.saveHeroChanges': 'save:hero:changes'
      'click @ui.heroCancel': 'load:map:modal'
      'click @ui.loadMap': 'load:selected:map'
      'click @ui.collect': 'collect:current:loot'

    onRender: ->
      $(document).keydown (e) =>
        e.preventDefault()

    selectItem: (args) ->
      item = $(args.currentTarget)
      unless parseInt($(item.children()[1]).text()) < 1
        if $('.checked-loot').length
          old = $('.checked-loot')
          old.removeClass('checked-loot')
          old.addClass('unchecked-loot')
        item.removeClass('unchecked-loot')
        item.addClass('checked-loot')

      #later will need to be as follows
      # if item.hasClass('checked-loot')
      #   item.removeClass('checked-loot')
      #   item.addClass('unchecked-loot')
      # else
      #   item.removeClass('unchecked-loot')
      #   item.addClass('checked-loot')

      @itemId = item.data('id')

    dropSelectedItem: (args) ->
      spell = $(args.currentTarget)
      @trigger "trigger:item:event", @itemId, spell.attr('id')

  class Show.LoadMap extends App.Views.ItemView
    template: 'lilrpg/show/load_map'
    tagName: "option"

  class Show.LoadMaps extends App.Views.CompositeView
    template: 'lilrpg/show/load_maps'
    childView: Show.LoadMap
    childViewContainer: "#load-select"
    events:
      'change #load-select': "getId"

    getId: (e) ->
      e.preventDefault
      target = e.currentTarget[e.currentTarget.selectedIndex]
      id = $($(target).children()).data("id")
      @trigger "select:current:map", id

  class Show.Show extends App.Views.ItemView
    template: 'lilrpg/show/_show'

    onRender: ->
      $(document).keydown (e) =>
        e.preventDefault()
        @trigger "player:action"

  class Show.Layout extends App.Views.Layout
    template: 'lilrpg/show/show_layout'
    regions:
      healthRegion: '#player-health'
      invRegion: '#inventory-region'
      lilrpgPlayRegion: '#lilrpg-play-region'
      dialogRegion: '#dialog-region'
