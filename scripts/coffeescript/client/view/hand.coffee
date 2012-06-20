root = exports ? this

root.HandView = Em.View.extend
	didInsertElement: ->
	templateName: 'hand'

	cardsInHandName: (-> 'hand' + @getPath 'hand.cardsInHand').property 'hand.cardsInHand'
