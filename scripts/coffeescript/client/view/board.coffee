root = exports ? this

root.BoardView = Em.View.extend
	templateName: 'board'
	boardBinding: 'App.viewStates.game.playing.board'
	playersBinding: 'App.viewStates.game.players'

	didInsertElement: ->
		deferred = queueAnimation @$(), @$('.player')
