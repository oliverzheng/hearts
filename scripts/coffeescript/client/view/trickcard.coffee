root = exports ? this

root.TrickCardView = Em.View.extend
	templateName: 'card'

	didInsertElement: ->
		#deferred = queueAnimation @$(), @$('.card')
