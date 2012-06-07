root = exports ? this

root.bind = bind = (context, func) -> $.proxy func, context

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

		[name, func] = @funcs.shift()
		@running = true

		defer bind @, ->
			#console.log @name, 'executing', name
			deferred = func()

			if deferred?.always?
				#console.log @name, 'deferred'
				deferred.always bind @, ->
					#console.log @name, 'deferred', name, 'finished', @funcs.length
					@running = false
					@ensureRunning()
			else
				@running = false
				#console.log @name, 'no deferred, next'
				# This has to be deferred. func() could have deferred functions
				# that queue up functions. We want to execute those first.
				defer bind @, @ensureRunning

	appendEndFunc: ->
		if @endFuncs.length is 0
			return false
		else
			@funcs.push @endFuncs.shift()
			#console.log 'appending to'
			@dump()
			#console.log 'from'
			@dumpEnd()
			return true

	queue: (name, func) ->
		@funcs.push [name, func]
		@dump()
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
		@endFuncs.push [name, func]
		@dumpEnd()
		@ensureRunning()
		return @

	queueDeferredEnd: (name, deferred) ->
		@queueEnd name, -> deferred
		return @

	dump: ->
		#console.log.apply #console, [name for [name, f] in @funcs]

	dumpEnd: ->
		#console.log.apply #console, [name for [name, f] in @endFuncs]
