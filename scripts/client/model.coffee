root = exports ? this
model = root.model ?= {}

model.UserCard = UserCard = Em.Object.extend
	card: null
	selected: false
	index: null

	selectableBinding: 'known'

	known: (-> @card? && @card.number? && @card.suit?).
		property 'card', 'card.number', 'card.suit'

	repr: (-> @card.repr() if @card).property()

	# For css classes
	indexName: (-> "card#{@index}").property()


model.Hand = Hand = Em.ArrayProxy.extend
	content: null

	init: ->
		if !@content
			@set 'content', []

	canPass: (->
		((@.filterProperty 'selected', true).get 'length') is 3
	).property '@each.selected'

	receive: (receivedCards) ->
		@removeObjects @filterProperty 'selected', true
		@pushObjects receivedCards

	played: (card) ->
		item = null
		@.forEach (handCard) ->
			if handCard.card && handCard.card.equals card
				item = handCard

		# If we haven't found it, all cards should be facing down. Pick a random
		# card.
		if !item
			item = @objectAt Math.floor Math.random() * @.get 'length'

		@removeObject item

Hand.reopenClass
	createUnknownHand: ->
		hand = Hand.create()
		for i in [1..13]
			card = UserCard.create
				index: i

			hand.pushObject card
		return hand


model.TrickCard = TrickCard = Em.Object.extend
	card: null
	seat: null

	repr: (-> @card.repr() if @card).property 'card'
	seatName: (-> Seat.toString @seat).property 'seat'


model.Trick = Trick = Em.ArrayProxy.extend
	content: null
	ending: false

	init: ->
		if !@content
			@set 'content', []

	cardAt: (seat) -> @content.findProperty 'seat', seat

	suit: (->
		if !@get 'empty'
			@content[0].card.suit
	).property '@each.card.suit'

	complete: (-> (@get 'length') >= Game.cardsPerTrick).property '@each'


model.Board = Board = Em.Object.extend
	passing: false
	pass: null
	heartsBroken: false
	trick: null


model.Player = Player = Em.Object.extend
	id: null
	name: null
	pictureUrl: null
	seat: null
	passed: false
	played: false
	hand: null
	roundPoints: 0
	gamePoints: 0

	seatName: (-> Seat.toString @seat).property 'seat'

	resetRound: ->
		@set 'passed', false
		@set 'played', false
		@set 'roundPoints', 0


model.Players = Players = Em.ArrayProxy.extend
	content: null

	init: ->
		if !@content
			@set 'content', []

	user: (-> @findProperty 'seat', Seat.Self).property '@each.seat'
