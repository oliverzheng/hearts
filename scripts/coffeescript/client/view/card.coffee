root = exports ? this

root.CardView = Em.View.extend
	templateName: 'card'

	didInsertElement: ->

	click: ->
		App.viewStates.send 'selectCard', @.card

	selectableBinding: 'card.selectable'

	queuePlayAnimation: (->
		if @getPath 'card.played'
			# IE10 (RP, at least) has a bug that jitters transitions when
			# another animation starts.
			animationD = queueAnimation @$(), @$('.card')
			waitD = App.viewStates.queue.createDeferred 'wait'
			animationD.always ->
				deferAfter 300, ->
					waitD.resolve()
	).observes 'card.played'

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
