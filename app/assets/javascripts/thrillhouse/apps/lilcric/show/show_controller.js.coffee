@Thrillhouse.module 'LilcricApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayout()
      @listenTo @layout, 'show', =>
        @showControls()
        @showPitch()
      @show @layout

    showControls: ->
      controlsView = @getControlsView()

      @listenTo controlsView, "bowl:the:ball", @getLocations

      @layout.controlRegion.show controlsView

    getLocations:(args) ->
      console.log "args", args
      preBounce = @getNewLocation($("#ball"),$('#good-pitch'))
      postBounce = @getNewLocation($("#good-pitch"),$('#wicket'))
      @animateBall(preBounce, postBounce)

    animateBall: (preBounce, postBounce) ->
      console.log "bounce locations", preBounce, postBounce
      $("#ball")
        .animate(
          left: "#{preBounce.left}px"
          top: "#{preBounce.top}px"
          ,
          1500
          )
        .animate(
          left: "#{postBounce.left}px"
          top: "#{postBounce.top}px"
          ,
          1500
          )

    showPitch: ->
      pitchView = @getPitchView()

      @layout.playRegion.show pitchView

    getLayout: ->
      new Show.Layout

    getControlsView: ->
      new Show.Controls

    getPitchView: ->
      new Show.Lilcric
