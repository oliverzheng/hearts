root = exports ? this

root.Pass = class Pass
	constructor: (@id, @repr, @nextPass, @getPasserIndex) ->

root.LeftPass = LeftPass = new Pass(0, '←', RightPass,
	(index) -> (index + Game.playersPerGame - 1) %  Game.playersPerGame)

root.RightPass = RightPass = new Pass(1, '→', AcrossPass,
	(index) -> (index + 1) % Game.playersPerGame)

root.AcrossPass = AcrossPass = new Pass(2, '↑', Keep,
	(index) -> (index + 2) % Game.playersPerGame)

root.Keep = Keep = LeftPass = new Pass(3, '↓', LeftPass)

root.FirstPass = root.LeftPass
