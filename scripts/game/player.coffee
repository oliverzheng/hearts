root = exports ? this

root.Player = class Player
	constructor: (@id) ->

	# Game level
	gamePoints: 0

	gameJoined: (@game) ->

	# Round level
	roundPoints: 0
	passed: false
	cards: null
	passedCards: null
	receivedCards: null

	hasCard: (targetCard) ->
		for card in @cards
			if card.equals targetCard
				return true
		return false

	removeCard: (targetCard) ->
		for card, index in @cards
			if card.equals targetCard
				@cards.splice index, 1
				return true
		return false

	setOutput: (@output) ->

	resetRound: ->
		@roundPoints = 0
		@passed = false
		@cards = []
		@passedCards = []

	dealtCards: (@cards) ->

	addRoundPoints: (points) ->
		@roundPoints += points

	addToGamePoints: ->
		@gamePoints += @roundPoints

	getPassFrom: (passer) ->
		for card in @passedCards
			@removeCard card
		@cards.push.apply(@cards, passer.passedCards)
		@receivedCards = passer.passedCards

	copyFrom: (player) ->
		@gamePoints = player.gamePoints
		@roundPoints = player.roundPoints

		@passed = player.passed
		@cards = player.cards
		@passedCards = player.passedCards

	pleasePlayCard: ->
