@Thrillhouse.module 'LilcricApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      options = App.request "get:lilcric:data"
      { @keycodes, @speeds, @goodPitch, @shortPitch, @fullPitch } = options
      @reporting = 0
      @layout = @getLayout()
      @liveBall = false
      @overCount = 1
      @ballCounter = 0
      @currentPitch = {}
      @shot = 0
      @scoresCollection = @createCollection()
      @oversCollection = new App.Entities.Collection
      @createFirstScoreColumn()
      @total = 0
      @totalBalls = 0
      @totalSR = 0

      @listenTo @layout, 'show', =>
        @showControls()
        @showPitch()
        @showScores()

      @show @layout

    createCollection: ->
      scores = new App.Entities.Collection
      scores

    createFirstScoreColumn: ->
      @createScoreModel
        runs: "Runs"
        action: "Shot"
        wicket: "Wicket?"
        pitch: "Length"
        speed: "Speed(kph)"

    createScoreModel: (options) ->
      delivery = new App.Entities.Model
        runs: options.runs
        wicket: options.wicket
        comment: options.comment
        pitch: options.pitch
        action: options.action
        speed: options.speed
      @scoresCollection.add delivery
      delivery

    showControls: ->
      @controlsView = @getControlsView()
      @listenTo @controlsView, "bowl:one:ball", @bowlOneBall
      @listenTo @controlsView, "bowl:one:over", @setupOver
      @listenTo @controlsView, "reset:game", @resetGame
      @listenTo @controlsView, "reporting:options", (value) =>
        @reporting = value

      @layout.controlRegion.show @controlsView
      $("#prematch-modal").modal('show');

    resetGame: ->
      @resetBallScores()
      @oversCollection.reset()
      @ballCounter = 0
      @overCount = 1
      @total = 0
      @totalSR = 0
      @totalBalls = 0
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
      $('.strike-rate').html(@totalSR)
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
      speeds = Math.round(@scoresCollection.getTotal('speed')/6)
      srate = Math.round(overTotal/6*100)
      wickets = @scoresCollection.filter( (x) ->
        x.get("wicket")
      ).length - 1
      @buildOver(overTotal, srate, wickets, speeds)
      @resetBallScores()
      @overCount += 1

    buildOver: (overTotal, srate, wickets, speeds) ->
      over = new App.Entities.Model
        over: @overCount
        runs: overTotal
        strike_rate: srate
        average_speed: speeds
        wickets: wickets
      @oversCollection.add over
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
        @calculateScore(shot.results)

    calculateScore: (shot) ->
      @createScoreModel(shot)
      @total += shot.runs
      @totalBalls += 1
      @displayResult(shot)
      @totalSR = Math.round(@total/@totalBalls*100)
      @shot = 0
      @reportingCheck(shot)

    displayResult: (shot) ->
      if shot.runs is 6
        size = "400%"
        color = "orange"
      else if shot.runs is 4
        size = "300%"
        color = "purple"
      else if shot.wicket
        color = "red"
        size = "200%"
      else
        size = "200%"
        color = "blue"
      @animateResult(shot,size,color)

    animateResult: (shot, size, color) ->
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
          700
        )
        .animate(
          fontSize: "100%"
          opacity: "0"
          ,
          300
        )

    reportingCheck: (shot) ->
      console.log "this is reporting", @reporting
      switch @reporting
        when 2
          @reportBall(shot)
        when 1
          if shot.wicket
            @reportBall(shot)
          else
            console.log "this is shot", shot
        when 0
          console.log "nothing to report"
        else
          console.log "why was there no reporting option (between 0 and 2)"

    reportBall: (shot) ->
      comment = ""
      if shot.comment
        comment += ", you #{shot.comment}"
      alert "You got #{shot.runs} runs with a #{shot.action}#{comment}."

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
