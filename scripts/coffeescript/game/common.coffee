root = exports ? this

root.deferAfter = deferAfter = (time, func) -> setTimeout func, time
root.defer = defer = (func) -> setTimeout func, 0

root.copy = copy = (obj) -> $.extend true, {}, obj

root.DeferredQueue = class DeferredQueue
	constructor: (@name) ->
		@running = false
		@funcs = []
		@endFuncs = []

	isEmpty: -> @funcs.length is 0

	ensureRunning: ->
		if @running
			return

		if @isEmpty() && !@appendEndFunc()
			return

		[name, func, logItem] = @funcs.shift()
		@running = true

		defer =>
			deferred = func()

			if deferred?.always?
				logItem.updateStatus 'deferred'

				deferred.always =>
					logItem.updateStatus 'done'
					logItem.updateSeverity info
					@running = false
					@ensureRunning()
			else
				logItem.updateStatus 'done'
				logItem.updateSeverity info

				@running = false
				# This has to be deferred. func() could have deferred functions
				# that queue up functions. We want to execute those first.
				defer => @ensureRunning()

	appendEndFunc: ->
		if @endFuncs.length is 0
			return false
		else
			@funcs.push @endFuncs.shift()
			return true

	queue: (name, func) ->
		logItem = log name
		logItem.updateStatus 'pending'
		logItem.updateExtras getCallstack()
		@funcs.push [name, func, logItem]
		@ensureRunning()
		return @

	queueDeferred: (name, deferred) ->
		@queue name, -> deferred
		return @

	createDeferred: (name) ->
		deferred = new $.Deferred
		@queueDeferred name, deferred
		return deferred

	queueEnd: (name, func) ->
		logItem = log name
		logItem.updateStatus 'pending end'
		logItem.updateExtras getCallstack()
		@endFuncs.push [name, func, logItem]
		@ensureRunning()
		return @

	queueDeferredEnd: (name, deferred) ->
		@queueEnd name, -> deferred
		return @
