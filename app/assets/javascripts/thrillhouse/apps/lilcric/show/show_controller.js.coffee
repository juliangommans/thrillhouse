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
        pick: 0
      @goodPitch =
        type: "good"
        bounce: -75
      @shortPitch =
        type: "short"
        bounce: -25
      @fullPitch =
        type: "full"
        bounce: -125
      @overCount = 1
      @ballCounter = 0
      @currentPitch = {}
      @shot = 0
      @scoresCollection = @createCollection()
      @oversCollection = new App.Entities.Collection
      @createFirstScoreColumn()
      @total = 0

      @listenTo @layout, 'show', =>
        @showControls()
        @showPitch()
        @showScores()
        # @showBallScores()
        # @showOversScores()

      @show @layout

    createCollection: ->
      scores = new App.Entities.Collection
      scores

    createFirstScoreColumn: ->
      @createScoreModel
        runs: "Runs"
        action: "Shot"
        wicket: "Wicket?"
        speed: "Speed(kph)"

    createScoreModel: (options) ->
      runs = new App.Entities.Model
        runs: options.runs
        wicket: options.wicket
        comment: options.comment
        action: options.action
        speed: options.speed
      @scoresCollection.add runs
      runs

    showControls: ->
      @controlsView = @getControlsView()
      @listenTo @controlsView, "bowl:one:ball", @bowlOneBall
      @listenTo @controlsView, "bowl:one:over", @setupOver
      @listenTo @controlsView, "reset:game", @resetGame

      @layout.controlRegion.show @controlsView

    resetGame: ->
      @resetBallScores()
      @oversCollection.reset()
      @ballCounter = 0
      @overCount = 1
      @total = 0
      @renderTotal()

    resetBallScores: ->
      @scoresCollection.reset()
      @createFirstScoreColumn()

    showScores: ->
      ballView = @getBallView()
      @layout.ballRegion.show ballView.view
      overView = @getOversView()
      @layout.overRegion.show overView.view

    getBallSpeed: ->
      speed = _.sample([110,130,150])
      animateSpeed = (200 - speed) * 7
      @speeds.animateBefore = animateSpeed
      @speeds.animateAfter = animateSpeed
      @speeds.pick = speed
      speed
####################################
    caluclateSpeeds: (speed) ->
####################################
    getBallPitch: ->
      pitch = _.sample([@shortPitch,@fullPitch,@goodPitch])
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
      deliveries = 5
      deliveryDelay = 4000
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
      # console.log "THIS IS THE PITCH", @currentPitch
      # console.log "and this is the SPEEEED", @speeds
      @liveBall = true
      preBounce = @getNewLocation($("#ball"),$("##{@currentPitch.type}-loc"), 10)
      postBounce = @getNewLocation($("#ball"),$("#batsman"), @currentPitch.bounce)
      @animateBall(preBounce, postBounce, ballSpeed)

    animateBall: (preBounce, postBounce, ballSpeed) ->
      endOfDelivery = 200 + @speeds.animateBefore + @speeds.animateAfter
      # console.log "bounce locations", preBounce, postBounce
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
      @ballCounter += 1
      @renderTotal()
      @resetDelivery()

    renderTotal: ->
      $('.total-runs').html(@total)
      if @ballCounter >= 6
        @getOverStats()
        @ballCounter = 0

    resetDelivery: ->
      $("#ball").animate(
        left: "0px"
        top: "0px"
        ,
        100
        )

    getOverStats: ->
      overTotal = @scoresCollection.getTotal('runs')
      srate = Math.round(overTotal/6*100)
      wickets = @scoresCollection.filter( (x) ->
        x.get("wicket")
      ).length - 1
      @buildOver(overTotal, srate, wickets)

    buildOver: (overTotal, srate, wickets) ->
      over = new App.Entities.Model
        over: @overCount
        runs: overTotal
        strike_rate: srate
        wickets: wickets
      @oversCollection.add over
      @resetBallScores()
      @overCount += 1
      over

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
        shot = {runs: 0, wicket: false, action: "leave", comment: "booo you offered no challenge, BOOOOOO....."}
        alert shot.comment
        @createScoreModel(shot)
      else
        action = @keycodes[@shot]
        shot = @getResults(action)
        console.log "shot", shot
        @calculateScore(shot.results)

    calculateScore: (shot) ->
      @createScoreModel(shot)
      @total += shot.runs
      @displayResult(shot)
      # extraComment = ""
      # if shot.comment
      #   extraComment = "and you #{shot.comment}"
      # if shot.wicket
      #   alert "WICKET - #{extraComment}"#You got #{shot.runs} runs from your #{shot.action} #{extraComment}"
      @shot = 0

    displayResult: (shot) ->
      if shot.runs is 6
        size = "300%"
        color = "orange"
      else if shot.runs is 4
        size = "250%"
        color = "purple"
      else if shot.wicket
        color = "red"
        size = "200%"
      else
        size = "200%"
        color = "blue"
      @animateResult(shot,size,color)

    animateResult: (shot, size, color) ->
      console.log "size and color", size, color
      if shot.wicket
        outcome = "WICKET"
      else
        outcome = "#{shot.runs}"
      $('.countdown').empty()
      $('.countdown').html(outcome)
      $('.countdown').css(
          color: color
        )
      $('.countdown')
        .animate(
          fontSize: size
          ,
          800
        )
        .animate(
          fontSize: "100%"
          opacity: "0"
          ,
          400
        )

    getResults: (action) ->
      App.request "lilcric:results",
        action: action
        pitch: @currentPitch.type
        speed: @speeds

    getLayout: ->
      new Show.Layout

    getBallView: ->
      App.request 'lilcric:score',
        collection: @scoresCollection
        table: "ball"

    getOversView: ->
      App.request 'lilcric:score',
        collection: @oversCollection
        table: "overs"

    getControlsView: ->
      new Show.Controls

    getPitchView: ->
      new Show.Lilcric
