root = exports ? this

root.App.ViewStates = Em.StateManager.extend
	queue: new DeferredQueue
	rootView: Em.ContainerView.create().appendTo 'body'
	initialState: 'main'

	main: Em.ViewState.create
		view: MainView

	game: Em.ViewState.create
		controller: null
		consoleOutput: null
		output: null
		players: null

		user: (-> @players.get 'user').property 'players.user'

		view: GameView

		enter: (stateManager, transition) ->
			@_super stateManager, transition

			@set 'players', model.Players.create()
			@set 'controller', new GameController
			@set 'consoleOutput', new ConsoleOutput
			#@set 'output', new OutputSplitter [@consoleOutput, @controller]
			@set 'output', @controller

		# Sub states

		waitingForPlayers: Em.ViewState.create
			view: WaitingForPlayersView

		playing: Em.ViewState.create
			board: null
			view: BoardView

			enter: (stateManager, transition) ->
				@_super stateManager, transition

				@set 'board', model.Board.create()


			round: Em.ViewState.create
				view: RoundView

				enter: (stateManager, transition) ->
					@_super stateManager, transition

					board = @getPath 'parentState.board'
					board.set 'heartsBroken', false

					players = @getPath 'parentState.parentState.players'
					players.forEach (player) -> player.resetRound()

				passing: Em.ViewState.create
					view: PassingView

					selectCard: (manager, card) ->
						user = manager.game.get 'user'
						if !user.passed && (card.selected || !user.hand.get 'canPass')
							card.toggleProperty 'selected'

					pass: (manager) ->
						user = manager.game.get 'user'
						if !user.passed
							user.set 'passed', true

				newTrick: Em.ViewState.create
					enter: (stateManager, transition) ->
						# TODO if this isn't here, Ember.js doesn't run this
						# state !?
						@_super stateManager, transition

				trick: Em.ViewState.create
					currentPlayer: null
					takingPlayer: null

					#view: TrickView

					enter: (stateManager, transition) ->
						@_super stateManager, transition

						board = @getPath 'parentState.parentState.board'
						board.set 'trick', model.Trick.create()

						user = @getPath 'parentState.parentState.parentState.user'
						user.set 'played', false

					trickEnding: Em.ViewState.create
						enter: (stateManager, transition) ->
							@_super stateManager, transition

							board = @getPath 'parentState.parentState.parentState.board'
							board.trick.set 'ending', true

					setPlayer: (manager, player) ->
						@set 'currentPlayer', player

						if (player is manager.game.get 'user') && (player.hand.someProperty 'selected', true)
							player.set 'played', true

					selectCard: (manager, card) ->
						user = manager.game.get 'user'
						if !user.played
							selected = user.hand.findProperty 'selected', true
							if selected && selected isnt card
								selected.set 'selected', false

							card.toggleProperty 'selected'

							if card.selected && user is @currentPlayer
								user.set 'played', true

			tallyPoints: Em.ViewState.create
				view: TallyPointsView


	# Actions

	createLocalGame: (stateManager) ->
		stateManager.goToState 'game'

		output = stateManager.getPath 'currentState.output'
		game = new Game output
		output.setGame game

		user = getUser()
		computers = getComputers 3

		defer ->
			game.addPlayer user
			defer ->
				game.addPlayer computers[0]
				defer ->
					game.addPlayer computers[1]
					defer -> game.addPlayer computers[2]
