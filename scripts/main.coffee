$ ->
	App.viewStates = App.ViewStates.create()
	App.viewStates.goToState 'game'
	App.viewStates.send 'createLocalGame'
