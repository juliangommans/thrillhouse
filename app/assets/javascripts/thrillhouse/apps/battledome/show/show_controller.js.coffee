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

      @listenTo @uiView, "reset:ui:points", (args) =>
        @postRenderUpdate()

      @layout.uiRegion.show @uiView
      @postRenderUpdate()

    initiateCombat: (args) ->
      combatOptions = {
        cooldowns: args.model.get('cooldowns')
        player: args.model.get('player')
        opponent: args.model.get('opponent')
        moves: @selectedMoves
      }
      results = App.request "battledome:combat", combatOptions
      console.log "this be the results", results
      unless results.outcome.length < 1
        @stripResults(results)
        @disableCombatButtons()

    checkActionPoints: (player, selectedMove) ->
      identifier = $(selectedMove).attr('id')
      move = @findItem(player.get('moves'), parseInt(identifier))
      ap = player.get('secondary_stats').action_points
      @checkZeroCd(move, selectedMove)
      if move.cost <= ap
        @assignMove(move)
        message = "<p>You selected #{$(selectedMove).text()}, you now have <b>#{ap - move.cost}</b> action points left</p>"
        @combatLogUpdate(message)
      else
        @notEnoughAp()

    checkZeroCd: (move,el) ->
      if move.cooldown is 0
        $(el).removeClass('selected')

    assignMove: (move) ->
      @selectedMoves.push(move)
      @addComboPoint()
      @deductActionPoints(move.cost)

    addComboPoint: ->
      total = @model.get('player').get('totals')["combo_points"]
      if @model.get('player').get('secondary_stats')["combo_points"] < total
        @model.get('player').get('secondary_stats')["combo_points"] += 1
        @postRenderUpdate()
      else
        @initiateComboBonus(total)

    initiateComboBonus: (total) ->
      bonus = confirm "would you like add a bonus to this move (+50% effectiveness)?"
      if bonus
        @selectedMoves[(@selectedMoves.length - 1)].bonus = true
        $('.combo-points').removeClass('available')
        @model.get('player').get('secondary_stats')["combo_points"] -= total

    unSelectMove: (player, selectedMove) ->
      identifier = $(selectedMove).attr('id')
      move = @findItem(player.get('moves'), parseInt(identifier))
      moveIndex = @selectedMoves.indexOf(move)
      if moveIndex > -1
        @selectedMoves.splice(moveIndex, 1)
      @addBackActionPoints(player, move)

    addBackActionPoints: (player, move) ->
      console.log "-1 move", @selectedMoves
      player.get('secondary_stats').action_points += move.cost
      ap = player.get('secondary_stats').action_points
      @combatLogUpdate("<p>You have unselected #{move.name}, you now have <b>#{ap}</b> points left</p>")
      @postRenderUpdate() #up", "action_points"

    findItem: (array, identifier) ->
      _.find(array, (item) ->
        item.id == identifier
      )

    findCooldown: (array, identifier) ->
      _.find(array, (move) ->
        move.move.id == identifier
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
      totalAp = @model.get('player').get('totals')["action_points"]
      currentAp = @model.get('player').get('secondary_stats').action_points
      @model.get('player').get('secondary_stats').action_points += (totalAp - currentAp)
      @uiView.render()
      @showView.render()
      @postRenderUpdate()

    deductActionPoints: (cost) ->
      console.log "+1 move", @selectedMoves
      @model.get('player').get('secondary_stats').action_points -= cost
      @pointsDisplay "down", "action_points"

    pointsDisplay: (direction, stat) ->
      switch stat
        when "action_points"
          modalArray = $('.modal-ap')
          uiArray = $('.ui-ap')
          @updateDisplay(modalArray, direction, stat)
          @updateDisplay(uiArray, direction, stat)
        when "combo_points"
          uiArray = $('.combo-points')
          @updateDisplay(uiArray, direction, stat)
        else
          alert "boourns - we don't know what points you want yo =>", stat

    updateDisplay: (array, direction, stat) ->
      available = @model.get('player').get('secondary_stats')[stat]
      total = @model.get('player').get('totals')[stat]
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
        @disableCombatButtons()
        @postRenderUpdate()
        if count >= total
          @finalizeRound time
          return
        else
          count++
        setTimeout looper, time
      looper()

    sortResultData: (result) ->
      owner = result.owner
      cooldowns = @model.get('cooldowns')[owner]
      @sortBuffs(result.move)
      @checkHealth(result)
      if result.move.cooldown >= 1
        unless @findCooldown(cooldowns, result.move.move.id)
          @model.get('cooldowns')[owner].push(result.move)
      @combatLogUpdate(result.message)

    sortBuffs: (move) ->
      target = @getBuffTarget(move)
      if move.buffs
        for buff in move.buffs
          foundBuff = @findItem(@model.get('buffs')[target], buff.id)
          @addBuff(foundBuff, buff, target)

    getBuffTarget: (move) ->
      if move.owner is "opponent"
        if move.move.stat_target is "opponent"
          return "player"
        else
          return "opponent"
      else
        if move.move.stat_target is "opponent"
            return "opponent"
          else
            return "player"

    addBuff: (foundBuff, buff, target) ->
      if foundBuff
        console.log "FOUND BUFF", foundBuff
        unless foundBuff.stacks >= foundBuff.max_stacks
          foundBuff.stacks += 1
      else
        @model.get('buffs')[target].push(buff)
        foundBuff = @findItem(@model.get('buffs')[target], buff.id)
        foundBuff.stacks += 1

    assignStatChanges: ->
      for character in ["player", "opponent"]
        console.log "#{character}s buffs =>", @model.get('buffs')[character]
        @resetStats(character)
        unless @model.get("buffs")[character].length < 1
          @adjustStats(character)

    resetStats: (character) ->
      for k, v of @model.get(character).get('base_stats')
        unless k is "health"
          v = @model.get(character).get('totals').k

    adjustStats: (character) ->
      console.log "we're adjusting stats for #{character}"
      buffs = @model.get("buffs")[character]
      for buff in buffs
        @updateStat(character, buff)

    updateStat: (char, buff) ->
      newStat = @model.get(char).get('base_stats')[buff.stat] *= @buffModifier(buff)
      @model.get(char).get('base_stats')[buff.stat] = Math.round(newStat)

    buffModifier: (buff) ->
      buffValue = 1
      modifier = buff.value * buff.stacks
      if buff.buff_type is "increase"
        buffValue += modifier
      else
        buffValue -= modifier
      return buffValue

    checkHealth: (result) ->
      targetTotal = @model.get(result.target).get('totals').health
      ownerTotal = @model.get(result.owner).get('totals').health
      outcome = if result.move.move.category is "damage" then result.healthChange else 0 - result.healthChange
      @model.get(result.target).get('base_stats').health -= outcome
      if @model.get(result.target).get('base_stats').health >= targetTotal
        @model.get(result.target).get('base_stats').health = targetTotal

    adjustHealthBar: (target) ->
      targetHp = @model.get(target).get('base_stats').health
      totalHp = @model.get(target).get('totals').health
      newHp = Math.round(targetHp/totalHp*100)
      $("##{target}-current-hp").width("#{newHp}%")
      @checkHealthColor(newHp, target)

    checkHealthColor: (percent, target) ->
      if percent < 60 and percent > 25
        $("##{target}-current-hp").css("background-color","orange")
      else if percent < 25
        $("##{target}-current-hp").css("background-color","red")
      else
        $("##{target}-current-hp").css("background-color","lightgreen")

    checkBonuses: ->
      for move in @model.get('player').get('moves')
        if move.bonus
          move.bonus = false

    finalizeRound: (time) ->
      @cooldownUpdates()
      setTimeout @resolveRound, time
      console.log "current model", @model

    resolveRound: =>
      @combatLogUpdate("<p><b>End of round #{@model.get('round').count}</b></p><hr>")
      @model.get('round').count += 1
      @combatLogUpdate("<p><b>Beginning of round #{@model.get('round').count}</b></p>")
      @checkBonuses()
      @assignStatChanges()
      @resetUi()
      @postRenderUpdate()

    cooldownUpdates: ->
      cooldowns = @model.get('cooldowns').player
      for cd in cooldowns.slice(0).reverse()
        console.log "cd", cd
        cd.cooldown -= 1
        if cd.cooldown < 1
          move = @findCooldown(cooldowns, cd.move.id)
          moveIndex = cooldowns.indexOf(move)
          if moveIndex > -1
            @model.get('cooldowns').player.splice(moveIndex, 1)

    postRenderUpdate: ->
      @pointsDisplay "up", "action_points"
      @pointsDisplay "up", "combo_points"
      for person in ["player", "opponent"]
        @adjustHealthBar(person)
        @checkStatsDisplay(person)
      @checkCooldowns()

    checkStatsDisplay: (person) ->
      data = @model.get(person)
      for stat, value of data.get('base_stats')
        if data.get('totals')[stat] > value
          @changeStatColour(person, stat, "red")
        else if data.get('totals')[stat] < value
          @changeStatColour(person, stat, "green")
        else
          @changeStatColour(person, stat, "black")

    changeStatColour: (person, stat, colour) ->
      if  $("##{person}-#{stat}")
        $("##{person}-#{stat}").css("color", colour)

    checkCooldowns: ->
      array = $('.player-moves')
      cooldowns = @getCooldowns()
      for move in [0..(array.length-1)]
        if @findItem(cooldowns, parseInt($(array[move]).attr('id')))
          @disableButtons(array[move])

    getCooldowns: ->
      cooldowns = []
      for item in @model.get('cooldowns').player
        cooldowns.push(item.move)
      return cooldowns

    disableCombatButtons: ->
      array = $('.in-combat')
      for button in [0..(array.length-1)]
        @disableButtons($(array[button]))

    createBattleModel: (player, opponent) ->
      new Backbone.Model
        player: player
        opponent: opponent
        round:
          count: 1
        cooldowns:
          player: []
          opponent: []
        buffs:
          player: []
          opponent: []

    getShowView: (model) ->
      new Show.Battledome
        model: model

    getUiView: (model) ->
      new Show.Ui
        model: model
