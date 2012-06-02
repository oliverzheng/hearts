root = exports ? this

root.TallyPointsView = Em.View.extend
	templateName: 'tallyPoints'

	didInsertElement: ->
		deferred = App.viewStates.queue.createDeferred 'tallyPoints'
		App.viewStates.game.players.forEach (player) ->
			$({
				roundPoints: player.roundPoints
				gamePoints: player.gamePoints
			}).animate {
				roundPoints: 0
				gamePoints: player.gamePoints + player.roundPoints
			}, {
				duration: 2000,
				step: ->
					player.set 'roundPoints', Math.ceil this.roundPoints
					player.set 'gamePoints', Math.ceil this.gamePoints
				complete: ->
					deferred.resolve()
			}
