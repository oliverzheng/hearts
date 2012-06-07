root = exports ? this

root.assert = (condition, message) ->
	if !condition
		throw (if message then new Error(message) else new Error())
