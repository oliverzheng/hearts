root = exports ? this

root.CardView = Em.View.extend
	didInsertElement: ->

	click: ->
		App.viewStates.send 'selectCard', @.card
