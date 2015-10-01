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

    checkActionPoints: (player, selectedMove) ->
      identifier = parseInt($(selectedMove).attr('id'))
      move = @findMove(player.get('moves'), identifier)
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
      identifier = parseInt($(selectedMove).attr('id'))
      move = @findMove(player.get('moves'), identifier)
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


    findMove: (array, identifier) ->
      _.find(array, (move) ->
        move.id == identifier
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
        @uiView.render()
        @showView.render()
        if count >= total
          @finalizeRound time
          return
        else
          count++
        setTimeout looper, time
      looper()

    sortResultData: (result) ->
      cooldowns = @model.get('cooldowns').player
      console.log "this is the cooldowns before", cooldowns
      @checkHealth(result)
      if result.move.cooldown >= 1
        unless @findMove(cooldowns, result.move.id)
          @model.get('cooldowns').player.push(result.move)
      @combatLogUpdate(result.message)

    checkHealth: (result) ->
      if result.target is "player"
        @model.get('player').get('base_stats').health += result.healthChange
      else
        @model.get('opponent').get('base_stats').health -= result.healthChange

    finalizeRound: (time) ->
      @roundUpdates()
      setTimeout @resolve, time
      console.log "current model", @model

    resolve: =>
      @combatLogUpdate("<p><b>End of round #{@model.get('round').count}</b></p><hr>")
      @model.get('round').count += 1
      @combatLogUpdate("<p><b>Beginning of round #{@model.get('round').count}</b></p>")
      @resetUi()

    roundUpdates: ->
      cooldowns = @model.get('cooldowns').player
      console.log "this is the cooldowns, after", cooldowns
      for cd in cooldowns.slice(0).reverse()
        cd.cooldown -= 1
        if cd.cooldown < 1
          move = @findMove(cooldowns, cd.id)
          moveIndex = cooldowns.indexOf(move)
          if moveIndex > -1
            @model.get('cooldowns').player.splice(moveIndex, 1)

    createBattleModel: (player, opponent) ->
      new Backbone.Model
        player: player
        opponent: opponent
        round:
          count: 1
        cooldowns:
          player: []
          opponent: []

    getShowView: (model) ->
      new Show.Battledome
        model: model

    getUiView: (model) ->
      new Show.Ui
        model: model
