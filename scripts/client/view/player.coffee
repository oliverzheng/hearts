root = exports ? this

root.PlayerView = Em.View.extend
	templateName: 'player'

	playersTurn: (->
		return App.viewStates.game.playing.round.trick.currentPlayer is @get 'player'
	).property 'App.viewStates.game.playing.round.trick.currentPlayer'
