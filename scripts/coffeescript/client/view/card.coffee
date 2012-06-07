root = exports ? this

root.CardView = Em.View.extend
	didInsertElement: ->
	templateName: 'card'

	click: ->
		App.viewStates.send 'selectCard', @.card
