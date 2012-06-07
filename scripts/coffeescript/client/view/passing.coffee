root = exports ? this

root.PassingView = Em.View.extend
	templateName: 'passing'
	boardBinding: 'App.viewStates.game.playing.board'
	userBinding: 'App.viewStates.game.players.user'

	didInsertElement: ->

	pass: ->
		App.viewStates.send 'pass'
