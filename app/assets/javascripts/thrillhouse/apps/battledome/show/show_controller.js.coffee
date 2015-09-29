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

    getLayout: ->
      new Show.Layout

    showView: (model) ->
      showView = @getShowView(model)
      @layout.displayRegion.show showView

    uiView: (model) ->
      uiView = @getUiView(model)

      @listenTo uiView, "check:action:points", (view, element) =>
        player = element.model.get('player')
        selectedMove = view.currentTarget
        @checkActionPoints(player, selectedMove)

      @listenTo uiView, "clear:chosen:moves", (args) =>
        @resetUi args
        @combatLogUpdate("You have successfully cleared your selection.")

      @listenTo uiView, "unselect:this:move", (view, element) =>
        player = element.model.get('player')
        selectedMove = view.currentTarget
        @unSelectMove(player, selectedMove)

      @layout.uiRegion.show uiView
      @pointsDisplay("up")

    checkActionPoints: (player, selectedMove) ->
      move = @findMove(player, selectedMove)
      cost = move.cost
      ap = player.get('secondary_stats').action_points
      if cost <= ap
        @selectedMoves.push(move)
        @deductActionPoints(player,cost)
        message = "You selected #{$(selectedMove).text()}, you now have #{ap - cost} action points left"
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
      $('#combat-log-region').append("#{message} <hr>")

    resetUi: (args) ->
      @selectedMoves.length = 0
      totalAp = args.model.get('player').get('total_ap')
      currentAp = args.model.get('player').get('secondary_stats').action_points
      args.model.get('player').get('secondary_stats').action_points += (totalAp - currentAp)
      @pointsDisplay("up")
      $('.player-moves').removeClass('selected')
      $('.selected-last').removeClass('selected-last')

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

    createBattleModel: (player, opponent) ->
      new Backbone.Model
        player: player
        opponent: opponent

    getShowView: (model) ->
      new Show.Battledome
        model: model

    getUiView: (model) ->
      new Show.Ui
        model: model
