root = exports ? this

root.Computer = class Computer extends Player
	pleasePassCards: ->
		@passedCards = @cards[0..2]
		@passed = true
		defer => @game.playerPassed @

	pleasePlayCard: ->
		# TODO do something smarter here eh
		for card in @cards
			if @game.canPlayCard @, card
				@removeCard card
				defer => @game.playCard card
				return

		# We must be able to play at least 1 card
		throw new Error

root.getComputers = (count) -> new Computer(-index) for index in [1..count]
