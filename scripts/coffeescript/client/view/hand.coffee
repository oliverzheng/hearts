root = exports ? this

root.HandView = Em.View.extend
	didInsertElement: ->
	templateName: 'hand'

	handClass: (->
		cardsInHand = @getPath 'hand.cardsInHand'
		if cardsInHand?
			'hand' + @getPath 'hand.cardsInHand'
	).property 'hand.cardsInHand'

	prevHandClass: (->
		hand = @get 'hand'
		if hand?.get 'played'
			'hand' + hand.get 'length'
	).property 'hand.played', 'hand.length'


	prevCardClass: (->
		hand = @get 'hand'
		if hand && hand.get 'played'
			return 'card1'
	).property 'hand.played'

	cardClass: (->
		hand = @get 'hand'
		if hand
			if hand.get 'played'
				return 'card0'
			else
				return 'card1'
	).property 'hand.played'

	waitingToPlay: (->
		!@getPath 'hand.played'
	).property 'hand.played'

	nthToGo: (->
		players = @get 'players'
		nth = players.nthToGo @get 'player'
		if nth?
			switch nth
				when 0 then 'firstToGo'
				when 1 then 'secondToGo'
				when 2 then 'thirdToGo'
				when 3 then 'fourthToGo'
	).property 'players.@each.firstToGo'
