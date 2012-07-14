root = exports ? this

root.CardView = Em.View.extend
	templateName: 'card'

	didInsertElement: ->

	selectCard: ->
		App.viewStates.send 'selectCard', @.card

	selectableBinding: 'card.selectable'

	queuePlayAnimation: (->
		if @getPath 'card.played'
			#App.viewStates.queue.createDeferred 'derp'
			#return
			queueAnimation @$(), @$('.card')
	).observes 'card.played'

	# IE10 (RP, at least) has a bug that jitters transitions when another
	# animation starts. Let's wait for the cards finish sliding over.
	waitForCardsToSlideOver: (->
		if (@getPath 'card.played') && !(@getPath 'card.inHand')
			wait = App.viewStates.queue.createDeferred 'wait'
			deferAfter 400, ->
				wait.resolve()
	).observes 'card.played', 'card.inHand'

	indexName: (-> 'card' + @getPath 'card.index').property 'card.index'

	prevCardClass: (->
		hand = @get 'hand'
		if hand && hand.get 'played'
			cardPlayed = hand.get 'cardPlayed'
			card = @get 'card'
			if cardPlayed.index <= card.index
				'card' + (card.index + 1)
	).property 'hand.played', 'card.index'

	cardClass: (-> 'card' + @getPath 'card.index').property 'card.index'
