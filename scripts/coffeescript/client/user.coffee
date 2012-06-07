root = exports ? this

root.User = class User extends Player
	pleasePassCards: ->

# TODO
user = new User 0

root.getUser = -> user
