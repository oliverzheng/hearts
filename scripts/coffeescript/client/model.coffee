root = exports ? this
model = root.model ?= {}

compareSuit = (a, b) ->
	order =
		# This the suit's id : order
		0: 0
		1: 1
		2: 2
		3: 3
	return order[a.id] - order[b.id]

Card = Em.Object.extend
	card: null

	numberName: (->
		names =
			1: 'ace'
			2: 'two'
			3: 'three'
			4: 'four'
			5: 'five'
			6: 'six'
			7: 'seven'
			8: 'eight'
			9: 'nine'
			10: 'ten'
			11: 'jack'
			12: 'queen'
			13: 'king'
		return names[@card?.number]
	).property 'card'

	numberSymbol: (->
		switch @card?.number
			when 1 then 'A'
			when 10 then '=' # The font requires this
			when 11 then 'J'
			when 12 then 'Q'
			when 13 then 'K'
			else @card?.number
	).property 'card'

	repr: (-> @card.repr() if @card).property 'card'


model.UserCard = UserCard = Card.extend
	card: null
	selected: false
	index: null
	played: false
	inHand: true
	finishing: false

	dealt: false # Dealt by the dealer
	passing: false # Passing to another player
	finishedPassing: false
	passed: false # Passed from another player

	selectable: (-> (@get 'known') && !@played && !@selected).property 'known', 'played', 'selected'

	known: (-> @card? && @card.number? && @card.suit?).
		property 'card', 'card.number', 'card.suit'

	unknown: (-> !@.get 'known').property 'known'


model.Hand = Hand = Em.ArrayProxy.extend
	content: null

	init: ->
		if !@content
			@set 'content', []

	canPass: (->
		((@.filterProperty 'selected', true).get 'length') is 3
	).property '@each.selected'

	finishedPassing: ->
		for card in @filterProperty 'passing', true
			card.set 'finishedPassing', true

	receive: (receivedCards) ->
		@removeObjects @filterProperty 'passing', true

		for card in receivedCards
			card.set 'passed', true
		@pushObjects receivedCards
		@sort()

	finishedReceiving: ->
		received = @filterProperty 'passed', true
		for card in received
			card.set 'passed', false

	playedCard: (card) ->
		item = null
		@forEach (handCard) ->
			if handCard.card && handCard.card.equals card
				item = handCard

		# If we haven't found it, all cards should be facing down. Pick a random
		# card.
		if !item
			item = @objectAt Math.floor Math.random() * @.get 'length'
			item.set 'card', card

		item.set 'played', true
		item.set 'selected', false

	finishPlayingCard: ->
		cardPlayed = @findProperty 'played', true
		cardPlayed.set 'inHand', false

		# Move indices up
		@filter (card, i, self) ->
			if card.index > cardPlayed.index
				card.decrementProperty 'index'

	played: (-> @someProperty 'played', true).property '@each.played'

	cardPlayed: (-> @findProperty 'played', true).property '@each.played'

	sort: ->
		sorted = @.slice 0
		sorted.sort (a, b) ->
			suit = compareSuit(a.card.suit, b.card.suit)
			if suit isnt 0
				return suit

			return compareNumber a.card.number, b.card.number

		@.forEach (card) ->
			i = sorted.indexOf card
			if card.index isnt i
				card.set 'index', i

	cardsInHand: (-> (@filterProperty 'inHand', true).get 'length').property '@each.inHand'

	trickFinishing: ->
		card = @findProperty 'played', true
		card.set 'finishing', true

	trickFinished: ->
		card = @findProperty 'finishing', true
		@removeObject card

Hand.reopenClass
	createUnknownHand: ->
		hand = Hand.create()
		for i in [0..12]
			card = UserCard.create
				index: i
				dealt: true

			hand.pushObject card
		return hand


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
	hisTurn: false
	firstToGo: false
	hand: null
	roundPoints: 0
	gamePoints: 0

	seatName: (-> Seat.toString @seat).property 'seat'

	resetRound: ->
		@set 'passed', false
		@set 'played', false
		@set 'roundPoints', 0

	isSelf: (-> @seat is Seat.Self).property 'seat'
	isAcross: (-> @seat is Seat.Across).property 'seat'
	isRight: (-> @seat is Seat.Right).property 'seat'
	isLeft: (-> @seat is Seat.Left).property 'seat'


model.Players = Players = Em.ArrayProxy.extend
	content: null

	init: ->
		if !@content
			@set 'content', []

	user: (-> @findProperty 'seat', Seat.Self).property '@each.seat'

	nthToGo: (player) ->
		first = @findProperty 'firstToGo', true
		if first
			return Seat.distance first.seat, player.seat
