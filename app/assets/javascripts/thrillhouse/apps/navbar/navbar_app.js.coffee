@Thrillhouse.module 'NavbarApp', (NavbarApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    show: ->
      new NavbarApp.Show.Controller
        region: App.navbarRegion

  NavbarApp.on 'start', ->
    API.show()