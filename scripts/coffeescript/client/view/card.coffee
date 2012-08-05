root = exports ? this

root.CardView = Em.View.extend
	templateName: 'card'

	selectCard: ->
		App.viewStates.send 'selectCard', @.card

	selectableBinding: 'card.selectable'

	queuePlayAnimation: (->
		if @getPath 'card.played'
			queueAnimation @$(), @$('.card')
	).observes 'card.played'

	queuePassingAnimation: (->
		if (@getPath 'player.isSelf') && (@getPath 'card.passing')
			queueAnimation @$(), @$('.card.passing')
	).observes 'card.passing'

	hasDealtAnimation: false
	hasPassedAnimation: false

	hide: ( ->
		return ((@getPath 'card.dealt') && !@hasDealtAnimation) ||
				((@getPath 'card.passed') && !@hasPassedAnimation)
	).property 'hasDealtAnimation', 'hasPassedAnimation', 'card.passed'

	# dealt and passed are applied before we are in the DOM.
	didInsertElement: ->
		if @getPath 'card.dealt'
			animationD = queueAnimation @$(), @$('.card.dealt')
			defer =>
				@set 'hasDealtAnimation', true

		else if (@getPath 'player.isSelf') && (@getPath 'card.passed')
			animationD = queueAnimation @$(), @$('.card')
			waitD = App.viewStates.queue.createDeferred 'waitForPassed'
			defer =>
				@set 'hasPassedAnimation', true

				# We want the effect of passed cards "pausing" after the swing
				# animation, but before they go into the hand. CSS animation has
				# a delay before the animation, but does not have a "linger" for
				# after the animation.
				# Here, we wait manually. See board.scss for the cardPassDelay.

				# We have to pass in a string selector, since it's possible our
				# "passed" class hasn't been assigned yet
				animationD.always ->
					deferAfter 600, ->
						waitD.resolve()

	resetDealt: (->
		if !(@getPath 'card.dealt')
			@set 'hasDealtAnimation', false
	).observes 'card.dealt'

	resetPassed: (->
		if !(@getPath 'card.passed')
			@set 'hasPassedAnimation', false
	).observes 'card.passed'

	# IE10 (RP, at least) has a bug that jitters transitions when another
	# animation starts. Let's wait for the cards finish sliding over.
	waitForCardsToSlideOver: (->
		if (@getPath 'card.played') && !(@getPath 'card.inHand')
			wait = App.viewStates.queue.createDeferred 'wait for cards to slide'
			deferAfter 400, ->
				wait.resolve()
	).observes 'card.played', 'card.inHand'

	waitForPassedTransition: (->
		if !(@getPath 'card.passed')
			wait = App.viewStates.queue.createDeferred 'wait for cards to drop'
			deferAfter 400, ->
				wait.resolve()
	).observes 'card.passed'


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
