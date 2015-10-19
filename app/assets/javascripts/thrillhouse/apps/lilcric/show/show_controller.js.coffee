@Thrillhouse.module 'LilcricApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayout()
      @liveBall = false
      @keycodes =
        32: "block"
        37: "pull"
        38: "hook"
        39: "cut"
        40: "drive"
      @speeds =
        110: "slow"
        130: "medium"
        150: "fast"
        animateBefore: 0
        animateAfter: 0
        pick: ""
      @goodPitch =
        type: "good"
        bounce: -75
      @shortPitch =
        type: "short"
        bounce: -25
      @fullPitch =
        type: "full"
        bounce: -125
      @currentPitch = {}
      @scoreTally = []
      @shot = 0

      @listenTo @layout, 'show', =>
        @showControls()
        @showPitch()

      @show @layout

    showControls: ->
      controlsView = @getControlsView()
      @listenTo controlsView, "bowl:one:ball", @bowlOneBall
      @listenTo controlsView, "bowl:one:over", @setupOver

      @layout.controlRegion.show controlsView

    getBallSpeed: ->
      speed = _.sample([110,130,150])
      animateSpeed = (200 - speed) * 7
      @speeds.animateBefore = animateSpeed
      @speeds.animateAfter = animateSpeed
      @speeds.pick = @speeds[speed]
      speed

    caluclateSpeeds: (speed) ->

    getBallPitch: ->
      pitch = @shortPitch# _.sample([@shortPitch,@fullPitch,@goodPitch])
      switch pitch.type
        when "short"
          @speeds.animateBefore /= 1.1
          @speeds.animateAfter *= 1.11
        when "full"
          @speeds.animateAfter /= 1.1
          @speeds.animateBefore *= 1.11
        when "good"
          console.log "all good homie"
        else
          console.log "NOT ALL GOOD AT ALL"
      pitch

    setupOver: (args) ->
      deliveries = 6
      deliveryDelay = 5000
      @overExecution(deliveryDelay, deliveries)


    overExecution: (delay, balls) ->
      console.log "over execution", delay
      over = =>
        @countdown(@setupDelivery,3)
        if balls--
          setTimeout over, delay
        else
          console.log "over is over... over"
      over()


    bowlOneBall: (args) ->
      @countdown(@setupDelivery,3)

    setupDelivery: ->
      ballSpeed = @getBallSpeed()
      @currentPitch = @getBallPitch()
      console.log "THIS IS THE PITCH", @currentPitch
      console.log "and this is the SPEEEED", @speeds
      @liveBall = true
      preBounce = @getNewLocation($("#ball"),$("##{@currentPitch.type}-loc"), 10)
      postBounce = @getNewLocation($("#ball"),$("#batsman"), @currentPitch.bounce)
      @animateBall(preBounce, postBounce, ballSpeed)

    animateBall: (preBounce, postBounce, ballSpeed) ->
      endOfDelivery = @speeds.animateBefore + @speeds.animateAfter
      console.log "bounce locations", preBounce, postBounce
      $("#ball")
        .animate(
          left: "#{preBounce.left}px"
          top: "#{preBounce.top}px"
          ,
          @speeds.animateBefore
          )
        .animate(
          left: "#{postBounce.left}px"
          top: "#{postBounce.top}px"
          ,
          @speeds.animateAfter
          )
      setTimeout(@finishDelivery, endOfDelivery)

    finishDelivery: =>
      @liveBall = false
      @selectShot()
      @resetDelivery()

    resetDelivery: ->
      $("#ball").animate(
        left: "0px"
        top: "0px"
        ,
        100
        )

    showPitch: ->
      pitchView = @getPitchView()
      @listenTo pitchView, "batter:action", @recordBattingAction

      @layout.playRegion.show pitchView

    recordBattingAction: ->
      event.preventDefault()
      filter = [32,37,38,39,40]
      if @liveBall
        if _.contains(filter, event.keyCode)
          @shot = event.keyCode
        else
          console.log "NAUGHTY"
      @liveBall = false

    selectShot: ->
      if @shot is 0
        alert "booo you offered no challenge, BOOOOOO....."
      else
        action = @keycodes[@shot]
        switch @currentPitch.type
          when "short"
            @calculateScore(action)
          else
            alert "you broke all of the things"

        console.log "you performed a #{action}"

    calculateScore: (action) ->
      shot = @getScore(action)
      @scoreTally.push(shot)
      extraComment = ""
      if shot.comment
        extraComment = "and you #{shot.comment}"
      alert "You got #{shot.runs} runs from your #{action} #{extraComment}"
      @shot = 0

    getScore: (action) ->
      switch action
        when "pull"
          {runs: 4, wicket: false, comment: ""}
        when "cut"
          {runs: 2, wicket: false, comment: ""}
        when "hook"
          {runs: 6, wicket: false, comment: ""}
        when "drive"
          {runs: 0, wicket: true, comment: "were caught in the slips"}
        when "block"
          {runs: 0, wicket: false, comment: "copped one right between the eyes"}


    getLayout: ->
      new Show.Layout

    getControlsView: ->
      new Show.Controls

    getPitchView: ->
      new Show.Lilcric
