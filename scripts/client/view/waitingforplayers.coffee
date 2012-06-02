root = exports ? this

root.WaitingForPlayersView = Em.View.extend
	templateName: 'waitingForPlayers'
	playersBinding: 'App.viewStates.currentState.parentState.players'

	didInsertElement: ->
		queueAnimation @$(), '.playerJoined', 4
