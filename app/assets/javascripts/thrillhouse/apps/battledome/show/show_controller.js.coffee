@Thrillhouse.module 'BattledomeApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      sampler = [1,2,3]
      @layout = @getLayout()
      @opponent = App.request "character:entity", _.sample(sampler)

      App.execute "when:fetched", @opponent, =>

        @player = App.request "character:entity", _.sample(sampler)
        App.execute "when:fetched", @player, =>

          @model = @createBattleModel(@player, @opponent)
          console.log "this is the battle model", @model
          @listenTo @layout, "show", =>
            @showView @model
            @uiView @model
          @show @layout

      @selectedMoves = []
      @cooldowns = []

    getLayout: ->
      new Show.Layout

    showView: (model) ->
      @showView = @getShowView(model)
      @layout.displayRegion.show @showView

    uiView: (model) ->
      @uiView = @getUiView(model)

      @listenTo @uiView, "check:action:points", (view, element) =>
        player = element.model.get('player')
        selectedMove = view.currentTarget
        @checkActionPoints(player, selectedMove)

      @listenTo @uiView, "clear:chosen:moves", =>
        @resetUi()
        @combatLogUpdate("You have successfully cleared your selection.")

      @listenTo @uiView, "unselect:this:move", (view, element) =>
        player = element.model.get('player')
        selectedMove = view.currentTarget
        @unSelectMove(player, selectedMove)

      @listenTo @uiView,  "confirm:chosen:moves", (args) =>
        @initiateCombat(args)
        @uiView.render()
        @showView.render()

      @listenTo @uiView, "reset:action:points", (args) =>
        @pointsDisplay("up")

      @layout.uiRegion.show @uiView
      @pointsDisplay("up")

    initiateCombat: (args) ->
      combatOptions = {
        player: args.model.get('player')
        opponent: args.model.get('opponent')
        moves: @selectedMoves
      }
      results = App.request "battledome:combat", combatOptions
      console.log "this be the results", results
      @stripResults(results)
      # @finalizeRound(results)
      results

    checkActionPoints: (player, selectedMove) ->
      move = @findMove(player, selectedMove)
      cost = move.cost
      ap = player.get('secondary_stats').action_points
      if cost <= ap
        @selectedMoves.push(move)
        @deductActionPoints(player,cost)
        message = "<p>You selected #{$(selectedMove).text()}, you now have <b>#{ap - cost}</b> action points left</p>"
        @combatLogUpdate(message)
      else
        @notEnoughAp()

    unSelectMove: (player, selectedMove) ->
      move = @findMove(player, selectedMove)
      moveIndex = @selectedMoves.indexOf(move)
      if moveIndex > -1
        @selectedMoves.splice(moveIndex, 1)
      @addBackActionPoints(player, move)

    addBackActionPoints: (player, move) ->
      console.log "-1 move", @selectedMoves
      player.get('secondary_stats').action_points += move.cost
      ap = player.get('secondary_stats').action_points
      @combatLogUpdate("<p>You have unselected #{move.name}, you now have <b>#{ap}</b> points left</p>")
      @pointsDisplay("up")


    findMove: (player, selectedMove) ->
      _.find(player.get('moves'), (move) ->
        move.id == parseInt($(selectedMove).attr('id'))
      )

    notEnoughAp: ->
      alert "not enough action point for this move"
      button = $('.selected-last')
      $(button).removeClass('selected')
      $(button).removeClass('selected-last')

    combatLogUpdate: (message) ->
      $('#combat-log-region').append("<p>#{message}</p>")

    resetUi: ->
      @selectedMoves.length = 0
      totalAp = @model.get('player').get('total_ap')
      currentAp = @model.get('player').get('secondary_stats').action_points
      @model.get('player').get('secondary_stats').action_points += (totalAp - currentAp)
      @uiView.render()
      @showView.render()

    deductActionPoints: (player,cost) ->
      console.log "+1 move", @selectedMoves
      player.get('secondary_stats').action_points -= cost
      @pointsDisplay "down"

    pointsDisplay: (direction) ->
      modalArray = $('.modal-ap')
      uiArray = $('.ui-ap')
      @updateDisplay(modalArray, direction)
      @updateDisplay(uiArray, direction)

    updateDisplay: (array, direction) ->
      available = @model.get('player').get('secondary_stats').action_points
      total = @model.get('player').get('total_ap')
      if direction is "up"
        if available > 0
          for item in [1..available]
            $(array[(item-1)]).addClass('available')
      else
        for item in [0..(total - available)]
          $(array[total - item]).removeClass('available')

    stripResults: (results) ->
      @delay(results.outcome,2000)

    delay: (array,time) ->
      count = 0
      total = array.length - 1
      looper = =>
        @sortResultData(array[count])
        if count >= total
          return
        else
          count++
        setTimeout looper, time
      looper()

    sortResultData: (result) ->
      console.log "result", result
      @checkHealth(result)
      if result.move.cooldown > 1
        @cooldowns.push(result.move)
      @combatLogUpdate(result.message)

    checkHealth: (result) ->
      if result.target is "player"
        @model.get('player').get('base_stats').health += result.healthChange
      else
        @model.get('opponent').get('base_stats').health -= result.healthChange

    finalizeRound: ->
      @combatLogUpdate("<p><b>End of round #{@model.get('round').count}</b></p><hr>")
      @model.get('round').count += 1
      @combatLogUpdate("<p><b>Beginning of round #{@model.get('round').count}</b></p>")
      @resetUi()

    createBattleModel: (player, opponent) ->
      new Backbone.Model
        player: player
        opponent: opponent
        round: {count: 1}

    getShowView: (model) ->
      new Show.Battledome
        model: model

    getUiView: (model) ->
      new Show.Ui
        model: model
