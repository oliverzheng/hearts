root = exports ? this

root.GameController = Em.Object.extend
	init: ->
		@gameQueue = App.viewStates.queue

	boardBinding: 'App.viewStates.game.playing.board'
	playersBinding: 'App.viewStates.game.players'
	userBinding: 'players.user'

	setConnection: (@connection) ->

	# User actions
	
	passCards: (->
		user = @get 'user'
		if user.passed
			cards = (c.card for c in user.hand.filterProperty 'selected', true)
			@game.remotePlayerPassed user.id, cards
			@connection?.passCards cards
	).observes 'user.passed'

	playCard: (->
		user = @get 'user'
		if user.played
			selected = (user.hand.findProperty 'selected', true)
			# This could be null, since user.played triggers when any player's
			# played triggers
			if selected
				card = selected.card
				@game.remotePlayerPlayed user.id, card
				@connection?.playCard card
	).observes 'user.played'

	# Interface to the game output
	
	setGame: (@game) ->
		@gameQueue.queueEnd 'setGame', ->
			App.viewStates.goToState 'waitingForPlayers'

	playerJoined: (player) ->
		# TODO this seat thing is local only?
		@seat ?= Seat.Self

		@gameQueue.queueDeferredEnd 'getProfile', (getHttpServer().getProfile player.id).then (profile) =>
			(@get 'players').pushObject model.Player.create
				id: player.id
				name: profile.name
				pictureUrl: profile.pictureUrl
				seat: @seat
			@seat += 1

	allPlayersJoined: ->
		@gameQueue.queueEnd 'allPlayersJoined', =>
			App.viewStates.goToState 'playing'

	newRound: ->

	dealtCards: (assignedCards) ->
		userCards = assignedCards[getUser().id]
		userHand = model.Hand.create()
		for card, i in userCards
			userHand.pushObject model.UserCard.create
				card: card
				index: i

		@gameQueue.queueEnd 'dealt', =>
			(@get 'players').forEach (player) ->
				if player.seat is Seat.Self
					player.set 'hand', userHand
				else
					player.set 'hand', model.Hand.createUnknownHand()
			App.viewStates.goToState 'round'

	passing: (pass) ->
		@gameQueue.queueEnd 'passing', =>
			(@get 'board').set 'passing', pass isnt Pass.Keep
			(@get 'board').set 'pass', pass
			App.viewStates.goToState 'passing'

	playerPassed: (player) ->
		if player.id isnt (@get 'user').id
			@gameQueue.queueEnd 'passed', =>
				((@get 'players').findProperty 'id', player.id).set 'passed', true

	receivedCards: (player) ->
		if player.id is (@get 'user').id
			@gameQueue.queueEnd 'received', =>
				cards = (model.UserCard.create {card: card} for card in player.receivedCards)
				((@get 'players').findProperty 'id', player.id).hand.receive cards

	startRound: (startingPlayer) ->

	newTrick: (startingPlayer) ->
		player = (@get 'players').findProperty 'id', startingPlayer.id
		@gameQueue.queueEnd 'startTrick', =>
			App.viewStates.goToState 'newTrick'
			App.viewStates.goToState 'trick'
			player.set 'firstToGo', true
			App.viewStates.send 'startWith', player

	playersTurn: (gamePlayer) ->
		#@gameQueue.queueEnd 'nextPlayer', =>
			#trick = (@get 'board').trick
			#if !trick.get 'complete'
				#nextPlayer = (@get 'players').findProperty 'seat', Seat.nextSeat player.seat
				#App.viewStates.send 'nextPlayer', nextPlayer

	cardPlayed: (gamePlayer, card) ->
		player = (@get 'players').findProperty 'id', gamePlayer.id
		@gameQueue.queueEnd ('cardPlayed ' + card.repr()), =>
			player.hand.playedCard card

		@gameQueue.queueEnd ('finishPlayingCard' + card.repr()), =>
			player.hand.finishPlayingCard()

	trickEnded: (taker, points) ->
		@gameQueue.queueEnd 'trickEnding', =>
			(@get 'players').forEach (player) ->
				player.hand.trickFinishing()

			takingPlayer = (@get 'players').findProperty 'id', taker.id
			if points > 0
				takingPlayer.incrementProperty 'roundPoints', points
			(App.viewStates.get 'currentState').set 'takingPlayer', takingPlayer
			App.viewStates.goToState 'trickEnding'

		@gameQueue.queueEnd 'trickEnded', =>
			(@get 'players').forEach (player) ->
				player.hand.trickFinished()
				player.set 'firstToGo', false

	roundEnded: ->
		@gameQueue.queueEnd 'roundEnded', =>
			App.viewStates.goToState 'tallyPoints'


	gameEnded: ->
	playerReplaced: ->
