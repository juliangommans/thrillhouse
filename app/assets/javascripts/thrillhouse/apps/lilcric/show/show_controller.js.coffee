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
      @unfilteredTotal = 0
      @totalSR = 0
      @unfilteredSR = 0
      @totalBalls = 0
      @wicketPenalty = 10
      @batLeft = 0
      @batTop = 0

      @listenTo @layout, 'show', =>
        @showControls()
        @showPitch()
        @showScores()

      @show @layout

      $(window).resize( =>
        @getSetBatPosition())
      @getSetBatPosition()

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

      @listenTo @controlsView, "show", ->
        $("#prematch-modal").modal('show');

      @listenTo @controlsView, "hide:modal", ->
        $('.modal-backdrop').remove();

      @layout.controlRegion.show @controlsView


    resetGame: ->
      @resetBallScores()
      @oversCollection.reset()
      @ballCounter = 0
      @overCount = 1
      @total = 0
      @unfilteredTotal = 0
      @unfilteredSR = 0
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
          console.log "good ball, no speed change"
        else
          console.log "NOT ALL GOOD AT ALL"
      pitch

    setupOver: (args) ->
      deliveries = 5
      deliveryDelay = 4000
      @overExecution(deliveryDelay, deliveries)

    overExecution: (delay, balls) ->
      over = =>
        @countdown(@setupDelivery,3)
        if balls--
          setTimeout over, delay
        else
          console.log "over is over... over"
      over()

    getSetBatPosition: ->
      @resetBat("show")
      @placeBat(true)
      batposition = @getNewLocation($("#down-swing"), $("#torso"), 0)
      @batTop = batposition.top + 37.5
      @batLeft = batposition.left + 15
      @placeBat(false)
      $("#fore-swing")[0].style.left = (@batLeft - 70) + "px"
      @resetBat("hide")
      $('#back-swing').show()

    resetBat: (action) ->
      for item in [0..2]
        bat = $('.bat')[item]
        if action is "show"
          $(bat).show()
        else
          $(bat).hide()

    placeBat: (reset) ->
      if reset
        @batLeft = 0
        @batTop = 0
      for item in [0..2]
        bat = $('.bat')[item]
        bat.style.left = @batLeft+"px"
        bat.style.top = @batTop+"px"

    animateBat: ->
      setTimeout(@downBat, @speeds.animateBefore)
    downBat: =>
      $('#back-swing').hide()
      $('#down-swing').show()
      setTimeout(@upBat, @speeds.animateAfter)
    upBat: =>
      $('#down-swing').hide()
      $('#fore-swing').show()

    bowlOneBall: (args) ->
      @countdown(@setupDelivery,3)

    setupDelivery: ->
      @getBallSpeed()
      @currentPitch = @getBallPitch()
      @liveBall = true
      preBounce = @getNewLocation($("#ball"),$("##{@currentPitch.type}-loc"), 10)
      postBounce = @getNewLocation($("#ball"),$("#batsman"), @currentPitch.bounce)
      @animateBall(preBounce, postBounce)

    animateBall: (preBounce, postBounce) ->
      @animateBat()
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
      @getSetBatPosition()
      @resetDelivery()

    renderTotal: ->
      $('.strike-rate').html(" #{@totalSR} (#{@unfilteredSR})")
      $('.total-runs').html(" #{@total} (#{@unfilteredTotal})")
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
      wickets = @scoresCollection.filter( (x) ->
        x.get("wicket")).length - 1
      overTotal = @scoresCollection.getTotal('runs')
      afterWickets = overTotal - @wicketPenalty * wickets
      speeds = Math.round(@scoresCollection.getTotal('speed')/6)
      srate = Math.round(afterWickets/6*100)
      beforeSrate = Math.round(overTotal/6*100)
      @buildOver(afterWickets, srate, beforeSrate, wickets, overTotal, speeds)
      alert "You have completed over #{@overCount}, your stats are: \n
      Runs: #{afterWickets} (#{overTotal}) \n
      Strike Rate: #{srate} (#{beforeSrate})\n
      Wickets: #{wickets}"
      @resetBallScores()
      @overCount += 1

    buildOver: (afterWickets, srate, beforeSrate, wickets, overTotal, speeds) ->
      over = new App.Entities.Model
        over: @overCount
        runs: afterWickets
        before_penalties: overTotal
        strike_rate: srate
        before_wickets_sr: beforeSrate
        average_speed: speeds
        wickets: wickets
      @oversCollection.add over
      over

    showPitch: ->
      pitchView = @getPitchView()
      @listenTo pitchView, "batter:action", @recordBattingAction
      @listenTo pitchView, "resize", @getSetBatPosition

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
        shot = {runs: 0, wicket: false, speed: @speeds[@speeds.pick], pitch: @currentPitch.type, action: "leave", comment: "booo you offered no challenge, BOOOOOO....."}
        alert shot.comment
        @createScoreModel(shot)
      else
        action = @keycodes[@shot]
        shot = @getResults(action)
        @calculateScore(shot.results)

    calculateScore: (shot) ->
      @createScoreModel(shot)
      @total += shot.runs
      @unfilteredTotal += shot.runs
      @totalBalls += 1
      @displayResult(shot)
      @totalSR = Math.round(@total/@totalBalls*100)
      @unfilteredSR = Math.round(@unfilteredTotal/@totalBalls*100)
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
        @total -= @wicketPenalty
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
