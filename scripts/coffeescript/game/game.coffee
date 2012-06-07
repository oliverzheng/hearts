root = exports ? this

root.Game = class Game
	constructor: (@output) ->
		@players = []

	# Game level

	isEveryoneHere: -> @players.length is Game.playersPerGame

	addPlayer: (player) ->
		if (!@isEveryoneHere())
			player.gameJoined(@)
			@players.push(player)
			@output.playerJoined(player)

			if (@isEveryoneHere())
				@output.allPlayersJoined(@players)
				@createRound(FirstPass)

	getUser: -> @players[0]

	createRound: (@currentPass) ->
		@currentPlayerIndex = null
		@curentTrick = null
		for player in @players
			player.resetRound()

		@output.newRound()

		@deal()

		@output.passing(@currentPass)

		if (@currentPass isnt Keep)
			for player in @players
				player.pleasePassCards()

	deal: ->
		cards = Card.allCards()
		# TODO shuffle!
		@players[0].dealtCards(cards[0..12])
		@players[1].dealtCards(cards[13..25])
		@players[2].dealtCards(cards[26..38])
		@players[3].dealtCards(cards[39..51])

		assignedCards = {}
		for player in @players
			assignedCards[player.id] = player.cards

		@output.dealtCards assignedCards

	getCurrentPlayer: -> @players[@currentPlayerIndex]

	playerPassed: (player) ->
		@output.playerPassed(player)
		if @players.every((player) -> player.passed)
			for player, index in @players
				passer = @players[@currentPass.getPasserIndex(index)]

				player.getPassFrom passer
				@output.receivedCards player

				if player.hasCard TwoOfClubs
					startingPlayer = player

			@startRound startingPlayer

	remotePlayerPassed: (playerId, cards) ->
		player = @players.findProperty 'id', playerId
		player.passed = true
		player.passedCards = cards
		@playerPassed player

	startRound: (startingPlayer) ->
		@startingPlayerIndex = @players.indexOf(startingPlayer)
		@output.startRound(startingPlayer)
		@heartsBroken = false

		@nthTrick = 1
		@startTrick()

	startTrick: ->
		@cardsPlayed = []
		@currentPlayerIndex = @startingPlayerIndex

		@output.newTrick(@getCurrentPlayer())

		@getCurrentPlayer().pleasePlayCard()

	canPlayCard: (player, card) ->
		if !player.hasCard card
			return false

		# 1st card of 1st trick: must two of clubs
		if @isFirstTrick() && @cardsPlayed.length is 0
			return card.equals TwoOfClubs

		# 1st card of all other tricks: no hearts unless hearts are broken, or
		# player only has hearts
		onlyHearts = true
		for c in player.cards
			if c.suit isnt Hearts
				onlyHearts = false
				break

		if @cardsPlayed.length is 0
			return @heartsBroken || card.suit isnt Hearts || onlyHearts

		# All other plays must be of the same suit if a card of that suit is
		# available
		hasCardsOfSuit = false
		for c in player.cards
			if c.suit is @getTrickSuit()
				hasCardsOfSuit = true
				break

		if hasCardsOfSuit && card.suit isnt @getTrickSuit()
			return false

		# No point cards on the 1st trick unless all cards have points
		onlyPointCards = true
		for c in player.cards
			if !c.hasPoints()
				onlyPointCards = false

		if @isFirstTrick()
			return !card.hasPoints() || onlyPointCards

		return true

	playCard: (card) ->
		@cardsPlayed.push(card)
		@output.cardPlayed(@getCurrentPlayer(), card)

		if @canEndTrick()
			@endTrick()
		else
			@currentPlayerIndex = (@currentPlayerIndex + 1) % Game.playersPerGame
			@getCurrentPlayer().pleasePlayCard()

	remotePlayerPlayed: (playerId, card) ->
		@playCard card

	canEndTrick: -> @cardsPlayed.length is Game.cardsPerTrick

	isFirstTrick: -> @nthTrick is 1
	isLastTrick: -> @nthTrick is Game.tricksPerRound

	getTrickSuit: -> @cardsPlayed[0].suit

	endTrick: ->
		takerIndex = -1
		takerNumber = -1
		totalPoints = 0
		for card, index in @cardsPlayed
			totalPoints += card.getPoints()

			if card.suit is @getTrickSuit() && (card.number is 1 ||
												takerNumber isnt 1 && card.number > takerNumber)
				takerNumber = card.number
				takerIndex = index
		takerIndex = (takerIndex + @startingPlayerIndex) % Game.playersPerGame

		taker = @players[takerIndex]
		taker.addRoundPoints(totalPoints)
		@output.trickEnded(taker, totalPoints)

		if !@isLastTrick()
			@startingPlayerIndex = takerIndex
			@nthTrick++
			@startTrick()
		else
			@endRound()

	endRound: ->
		for player in @players
			player.addToGamePoints()
		@output.roundEnded()

		if @canEndGame()
			@endGame()
		else
			@createRound(@currentPass.nextPass)

	canEndGame: -> @players.some (player) -> player.gamePoints >= Game.pointsToLose

	endGame: ->
		@output.gameEnded()

	replacePlayer: (player, sub) ->
		sub.copyFrom(player)
		@players.splice(@players.indexOf(player), 1, sub)
		@output.playerReplaced(player, sub)


Game.pointsToLose = 100
Game.tricksPerRound = 13
Game.playersPerGame = 4
Game.cardsPerTrick = 4
