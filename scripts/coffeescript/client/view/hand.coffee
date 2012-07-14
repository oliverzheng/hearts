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
