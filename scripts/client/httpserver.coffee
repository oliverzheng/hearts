root = exports ? this

# TODO stub
root.HttpServer = class HttpServer

	getProfile: (profileId) ->
		profiles =
			'0': new Profile 0, 'Derpina', 'http://openclipart.org/image/250px/svg_to_png/168635/Derpina.png'
			'-1': new Profile -1, 'Derp', 'http://i1.kym-cdn.com/photos/images/newsfeed/000/270/676/83b.png'
			'-2': new Profile -2, 'Oh stop it you', 'http://alltheragefaces.com/img/faces/png/happy-oh-stop-it-you.png'
			'-3': new Profile -3, 'Forever alone', 'http://alltheragefaces.com/img/faces/png/sad-forever-alone-happy.png'

		return (new $.Deferred).resolveWith @, [profiles[profileId]]

httpServer = new HttpServer

root.getHttpServer = -> httpServer
