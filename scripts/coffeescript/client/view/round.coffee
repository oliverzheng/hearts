root = exports ? this

root.RoundView = Em.View.extend
	templateName: 'round'
	boardBinding: 'App.viewStates.game.playing.board'
	playersBinding: 'App.viewStates.game.players'

	didInsertElement: ->
		#queueAnimation @$(), @$('.card')
