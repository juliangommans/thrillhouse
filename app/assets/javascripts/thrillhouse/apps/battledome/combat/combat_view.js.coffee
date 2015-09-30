@Thrillhouse.module 'BattledomeApp.Combat', (Combat, App, Backbone, Marionette, $, _) ->

  class Combat.Battledome extends App.Views.ItemView
    template: 'battledome/combat/_battledome'

  class Combat.Combat extends App.Views.ItemView
    template: 'battledome/combat/_combat'

  class Combat.Layout extends App.Views.Layout
    template: 'battledome/combat/combat_layout'
    regions:
      combatRegion: '#combat-region'