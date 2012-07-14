root = exports ? this

root.DebugView = Em.View.extend
	templateName: 'debug'
	collapsed: true
	tab: 'logging'

	collapseSymbol: (->
		if @collapsed
			return '+'
		else
			return '-'
	).property 'collapsed'

	toggleCollapse: ->
		@toggleProperty 'collapsed'

	collapseClass: (->
		if @collapsed
			'collapsed'
		else
			'expanded'
	).property 'collapsed'

	showCss: ->
		@set 'tab', 'css'

	showLogging: ->
		@set 'tab', 'logging'

	watchTimes: (->
		if App.cssWatch && App.cssWatch.time > 0
			return [0..(App.cssWatch.time - 1)]
	).property 'App.cssWatch.time'

root.AddCssWatchView = Em.TextField.extend
	insertNewline: ->
		value = @get 'value'

		if value
			watchCss value
