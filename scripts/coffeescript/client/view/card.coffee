root = exports ? this

root.CardView = Em.View.extend
	templateName: 'card'

	didInsertElement: ->

	click: ->
		App.viewStates.send 'selectCard', @.card

	selectable: -> true
