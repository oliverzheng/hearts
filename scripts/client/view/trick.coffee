root = exports ? this

root.TrickView = Em.View.extend
	templateName: 'trick'
	trickBinding: 'App.viewStates.game.playing.board.trick'
	takingSeatNameBinding: 'App.viewStates.game.playing.round.trick.takingPlayer.seatName'

	didInsertElement: ->

	endTrick: (->
		if (@get 'trick').ending
			queueAnimation @$(), @$('#trick')
	).observes 'trick.ending'
