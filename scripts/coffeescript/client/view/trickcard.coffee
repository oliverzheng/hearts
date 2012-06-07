root = exports ? this

root.TrickCardView = Em.View.extend
	didInsertElement: ->
		deferred = queueAnimation @$(), @$('.card')
