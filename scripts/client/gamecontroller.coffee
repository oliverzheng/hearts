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
			card = (user.hand.findProperty 'selected', true).card
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

		@gameQueue.queueDeferredEnd 'getProfile', (getHttpServer().getProfile player.id).then bind @, (profile) ->
			(@get 'players').pushObject model.Player.create
				id: player.id
				name: profile.name
				pictureUrl: profile.pictureUrl
				seat: @seat
			@seat += 1

	allPlayersJoined: ->
		@gameQueue.queueEnd 'allPlayersJoined', bind @, ->
			App.viewStates.goToState 'playing'

	newRound: ->

	dealtCards: (assignedCards) ->
		userCards = assignedCards[getUser().id]
		userHand = model.Hand.create()
		for card, i in userCards
			userHand.pushObject model.UserCard.create
				card: card
				index: i

		@gameQueue.queueEnd 'dealt', bind @, ->
			(@get 'players').forEach (player) ->
				if player.seat is Seat.Self
					player.set 'hand', userHand
				else
					player.set 'hand', model.Hand.createUnknownHand()
			App.viewStates.goToState 'round'

	passing: (pass) ->
		@gameQueue.queueEnd 'passing', bind @, ->
			(@get 'board').set 'passing', pass isnt Pass.Keep
			(@get 'board').set 'pass', pass
			App.viewStates.goToState 'passing'

	playerPassed: (player) ->
		if player.id isnt (@get 'user').id
			@gameQueue.queueEnd 'passed', bind @, ->
				((@get 'players').findProperty 'id', player.id).set 'passed', true

	receivedCards: (player) ->
		if player.id is (@get 'user').id
			@gameQueue.queueEnd 'received', bind @, ->
				cards = (model.UserCard.create {card: card} for card in player.receivedCards)
				((@get 'players').findProperty 'id', player.id).hand.receive cards

	startRound: (startingPlayer) ->

	newTrick: (startingPlayer) ->
		player = (@get 'players').findProperty 'id', startingPlayer.id
		@gameQueue.queueEnd 'startTrick', bind @, ->
			App.viewStates.goToState 'newTrick'
			App.viewStates.goToState 'trick'
			App.viewStates.send 'startWith', player

	cardPlayed: (gamePlayer, card) ->
		player = (@get 'players').findProperty 'id', gamePlayer.id
		@gameQueue.queueEnd ('cardPlayed' + card.repr()), bind @, ->
			player.hand.played card

			trick = (@get 'board').trick
			trick.pushObject model.TrickCard.create
				card: card
				seat: player.seat

		@gameQueue.queueEnd 'nextPlayer', bind @, ->
			trick = (@get 'board').trick
			if !trick.get 'complete'
				nextPlayer = (@get 'players').findProperty 'seat', Seat.nextSeat player.seat
				App.viewStates.send 'nextPlayer', nextPlayer

	trickEnded: (taker, points) ->
		@gameQueue.queueEnd 'trickEnded', bind @, ->
			takingPlayer = (@get 'players').findProperty 'id', taker.id
			if points > 0
				takingPlayer.incrementProperty 'roundPoints', points
			(App.viewStates.get 'currentState').set 'takingPlayer', takingPlayer
			App.viewStates.goToState 'trickEnding'

	roundEnded: ->
		@gameQueue.queueEnd 'roundEnded', bind @, ->
			App.viewStates.goToState 'tallyPoints'


	gameEnded: ->
	playerReplaced: ->
