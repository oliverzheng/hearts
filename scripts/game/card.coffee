root = exports ? this


root.Suit = class Suit
	constructor: (@name, @id, @repr) ->

root.Clubs = Clubs = new Suit('clubs', 0, '♣')
root.Diamonds = Diamonds = new Suit('diamonds', 1, '♦')
root.Spades = Spades = new Suit('spades', 2, '♠')
root.Hearts = Hearts = new Suit('hearts', 3, '♥')

Suit.allSuits = [Clubs, Diamonds, Spades, Hearts]


root.Card = class Card
	constructor: (@number, @suit) ->
		@unknown = !(@number? || @suit?)

	repr: -> "#{@number}#{@suit.repr}"

	equals: (other) -> other.number is @number && other.suit is @suit

	getPoints: ->
		if @number is 13 and @suit is Spades
			return 13
		else if @suit is Hearts
			return 1
		else
			return 0

	hasPoints: -> @getPoints() > 0

Card.allCards = ->
	cards = []
	for suit in Suit.allSuits
		for number in [1..13]
			cards.push new Card(number, suit)
	return cards

root.UnknownCard = UnknownCard = new Card
root.TwoOfClubs = TwoOfClubs = new Card 2, Clubs
