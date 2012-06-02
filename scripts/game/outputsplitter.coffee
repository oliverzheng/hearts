root = exports ? this

root.OutputSplitter = class OutputSplitter
	constructor: (@objects=[]) ->

	callAll: (methodName, args) ->
		for object in @objects
			object[methodName].apply(object, args)

	setGame: -> @callAll('setGame', arguments)
	playerJoined: -> @callAll('playerJoined', arguments)
	allPlayersJoined: -> @callAll('allPlayersJoined', arguments)
	newRound: -> @callAll('newRound', arguments)
	dealtCards: -> @callAll('dealtCards', arguments)
	passing: -> @callAll('passing', arguments)
	playerPassed: -> @callAll('playerPassed', arguments)
	startRound: -> @callAll('startRound', arguments)
	newTrick: -> @callAll('newTrick', arguments)
	cardPlayed: -> @callAll('cardPlayed', arguments)
	trickEnded: -> @callAll('trickEnded', arguments)
	roundEnded: -> @callAll('roundEnded', arguments)
	gameEnded: -> @callAll('gameEnded', arguments)
	playerReplaced: -> @callAll('playerReplaced', arguments)
