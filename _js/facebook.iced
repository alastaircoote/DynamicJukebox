class facebook
	permissions: ["user_actions.music"]
	appId: 333527893368697
	constructor: () ->
		window.fbInitFuncs = []
		this.isSpotify = typeof getSpotifyApi == "function"
		if this.isSpotify
			this.spotify = getSpotifyApi()
			if !$.cookie "access_token"
				auth = this.spotify.require('sp://import/scripts/api/auth')
				auth.authenticateWithFacebook this.appId, this.permissions,
					onSuccess: (accessToken,ttl) =>
						expiryDate = new Date().valueOf() + (ttl * 1000)
						$.cookie "access_token", accessToken, new Date(expiryDate)
						this.accessToken = accessToken
						this.timeToExpiry = ttl
						await this.doRequest "/me", defer data
						this.userData = data
						this.processInitFuncs()
			else
				
				this.accessToken = $.cookie "access_token"
				this.processInitFuncs()
		else
			$("body").append("<div id='fb-root'/>")
			window.fbAsyncInit = () =>
				FB.init
					appId: this.appId,
			      	status: true, # check login status
			      	cookie: false, # enable cookies to allow the server to access the session
			      	xfbml: false  # parse XFBML
				await FB.getLoginStatus defer response
				await this.doRequest "/me", defer data
				this.userData = data
				this.processInitFuncs()
			$.ajax
				url: "http://connect.facebook.net/en_US/all.js"
				dataType: "script"
				cache: true
	doRequest: (url, retFunc) =>
		if this.isSpotify
			url = "https://graph.facebook.com" + url
			if url.indexOf("?") > -1
				url += "&"
			else
				url += "?"
			url += "access_token=" + this.accessToken
			await $.getJSON url, defer data
			retFunc data, url
		else
			await FB.api url, defer data
			retFunc data, url
	getFriends: (retFunc) =>
		if !this.friendsList
			await this.doRequest "/me/friends?fields=name,picture&limit=100", defer data
			this.friendsList = data.data
			retFunc data.data
		else
			retFunc this.friendsList
	processInitFuncs: () =>
		for func in window.fbInitFuncs
			func()
		window.fbInitFuncs =
			push: (func)->
				func()
window.Facebook = facebook