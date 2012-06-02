root = exports ? this

root.queueAnimation = ($el, selector, times=1) ->
	# The selector can be live (a string) which will be evaluated on each
	# animationend. Else, it must be a jQuery object.
	isSelectorLive = selector && typeof selector is 'string'
	if selector && !isSelectorLive
		times = selector.length

	deferred = App.viewStates.queue.createDeferred 'animation'
	$el.bind 'animationend mozAnimationEnd webkitAnimationEnd msAnimationEnd', (e) ->
		if selector
			if isSelectorLive
				$selector = $el.find selector
			else
				# Should be a jQuery object
				$selector = selector
		else
			$selector = $el

		if $selector.is e.target
			times--

		if times <= 0
			deferred.resolve()

	return deferred
