root = exports ? this

root.ConsoleOutput = class ConsoleOutput
	setGame: (@game) ->

	playerJoined: (player) ->
		console.log player.id, 'joined'

	allPlayersJoined: ->
		console.log 'all players joined'

	newRound: (pass) ->
		console.log 'new round with pass', pass

	dealtCards: ->
		console.log 'cards dealt'

	passing: ->
		console.log 'passing round'

	playerPassed: (player) ->
		console.log player.id, 'player passed'

	startRound: ->
	newTrick: ->
	cardPlayed: ->
	trickEnded: ->
	roundEnded: ->
	gameEnded: ->
	playerReplaced: ->
