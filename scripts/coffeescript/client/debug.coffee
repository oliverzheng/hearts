root = exports ? this

padWith = (number, length, pad = '0') ->
	str = number.toString()
	while str.length < length
		str = pad + str
	return str

$.fn.distanceToParent = (parent) ->
	$this = $(this[0])
	if $this.is parent
		return 0

	if $this.closest(parent).length isnt 0
		return $this.parentsUntil(parent).andSelf().length;


Log = Em.Object.extend
	msg: null
	severity: null
	time: null
	status: null
	extras: null

	init: ->
		now = new Date
		hours = padWith now.getHours(), 2
		minutes = padWith now.getMinutes(), 2
		seconds = padWith now.getSeconds(), 2
		milliseconds = padWith now.getMilliseconds(), 3
		@set 'time', "#{hours}:#{minutes}:#{seconds}.#{milliseconds}"

		if !@extras
			@set 'extras', []

	updateStatus: (status) ->
		@set 'status', status

	updateSeverity: (severity) ->
		@set 'severity', severity

	updateExtras: (extras) ->
		@extras.pushObjects extras

root.debug = debug = 'debug'
root.info = info = 'info'

root.App.logs = logs = []

root.log = (msg) ->
	log = Log.create
		msg: msg
		severity: debug

	logs.pushObject log
	return log

root.getCallstack = ->
	try
		i.dingdongGUID.dont.exist += 0
	catch e
		if (e.stack)
			callstack = []
			lines = e.stack.split '\n'
			for line in lines
				if !line.match /dingdongGUID/
					callstack.push line

			# Remove call to printStackTrace()
			callstack.shift();
			return callstack


# Watch CSS classes

CssClass = Em.Object.extend
	className: null
	changes: null

	init: ->
		if !@changes
			@set 'changes', []

	changeAt: (time, apply) ->
		if @changes.length is 0 and apply is false
			# We've always been turned on, and now we want to turn off?
			@changes.pushObject [0, true]

		@changes.pushObject [time, apply]

	appliedAt: (time) ->
		applied = false
		changed = false
		for change in @changes
			[changeTime, changeApplied] = change
			if changeTime > time
				break
			if changeTime == time
				changed = true
			applied = changeApplied

		return [applied, changed]

	appliedList: (->
		if App.cssWatch && App.cssWatch.time > 0
			for time in [0..(App.cssWatch.time - 1)]
				[applied, changed] = @appliedAt time
				{ applied: applied, notApplied: !applied, changed: changed}
	).property 'App.cssWatch.time'

CssEl = Em.Object.extend
	classes: null
	level: null
	$el: null

	init: ->
		if !@classes
			@set 'classes', []

	getClass: (cssClass) ->
		for cls in @classes
			if cls.className is cssClass
				return cls

		cls = CssClass.create
			className: cssClass

		@classes.pushObject cls
		return cls

	addClass: (cssClass, time) ->
		cls = @getClass cssClass
		cls.changeAt time, true

	removeClass: (cssClass, time) ->
		cls = @getClass cssClass
		cls.changeAt time, false

CssWatch = Em.ArrayProxy.extend
	els: []
	$watchedEl: null
	time: 0

	init: ->
		if @$watchedEl
			@pushObject CssEl.create
				level: 0
				$el: @$watchedEl

	sort: ->
		@propertyWillChange 'els'

		@els.sort (a, b) ->
			return a.level - b.level

		@propertyDidChange 'els'

	getCssEl: ($el) ->
		for el in @els
			if el.$el.is $el
				return el

		distance = @$watchedEl.distanceToParent $el
		if distance?
			el = CssEl.create
				$el: $el
				level: distance

			@els.pushObject el
			@sort()

			return el

	addClass: ($el, cssClass) ->
		cssEl = @getCssEl $el
		if cssEl && !cssEl.$el.hasClass cssClass
			cssEl.addClass cssClass, @time

		@incrementProperty 'time'

	removeClass: ($el, cssClass) ->
		cssEl = @getCssEl $el
		if cssEl && cssEl.$el.hasClass cssClass
			cssEl.removeClass cssClass, @time

		@incrementProperty 'time'

root.App.cssWatch = null

# Replace the jQuery functions so we can track when CSS classes are modified.
if ENV && ENV.DEBUG
	addClassSav = $.fn.addClass
	removeClassSav = $.fn.removeClass

	$.fn.extend
		addClass: (value) ->
			if typeof value is 'string'
				root.App.cssWatch?.addClass $(this), value
			addClassSav.apply this, arguments

		removeClass: (value) ->
			if typeof value is 'string'
				root.App.cssWatch?.removeClass $(this), value
			removeClassSav.apply this, arguments


root.watchCss = (el) ->
	App.set 'cssWatch', CssWatch.create
		$watchedEl: $(el)
