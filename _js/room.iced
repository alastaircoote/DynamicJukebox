class room
	constructor: (data) ->
		this.roomData = data.room
		this.sp = getSpotifyApi(1)
		this.models = this.sp.require('sp://import/scripts/api/models')
		this.models.player.observe(this.models.EVENT.CHANGE, this.trackChanged)
		await this.grabTrackList defer empty
		$("#room").css "display", "block"
		$("#frontpageBack").css "display","none"
		if typeof getSpotifyApi != "undefined"
			this.isSpotify = true
			$(".albumart").css 
				"-webkit-transform": "none"#"rotate3d(-2, -2,0, 50deg)"
				"margin-left":"-10%"
			$("#room").css
				#{}"-webkit-perspective": -1000
		else
			this.isSpotify = false
		#	$(".albumart").css 	"-webkit-transform", "rotate3d(2, 1,0, 50deg)"
		#alert($(".albumart").css 	"-webkit-transform")
		
		console.log this.roomData.name
		$("#h1rmname").html this.roomData.name
		this.fillAlbumArt()
		this.setNowPlaying()
		this.setOccupants()
		this.trackRefresh()
	
	trackChanged: (e) =>
		#if e.data.curtrack == false
		#	return
		#this.playlist.tracks.remove(this.playlist.tracks[0])
		trackid= this.models.player.track.data.uri.replace("spotify:track:","")
		await $.getJSON baseUrl + "room/" + this.roomData.id + "/started.json?track_id=" + trackid + "&user[fb_id]=" + fBook.userData.id, null,defer data
		#await $.getJSON baseUrl + "room/" + this.roomData.id + "/tracks.json?&user[fb_id]=" + fBook.userData.id,null, defer data
		this.trackData = data
		newTrack = this.models.Track.fromURI("spotify:track:" + this.trackData.tracks[1])
		this.playlist.add(newTrack)
		this.currentTrack = this.models.player.track
		this.setNowPlaying()
	
	trackRefresh: () =>
		await
			$.getJSON baseUrl + "room/" + this.roomData.id + "/tracks.json?&user[fb_id]=" + fBook.userData.id,null, defer data
			$.getJSON baseUrl + "room/"+ this.roomData.id + ".json?user[fb_id]=" + fBook.userData.id, null, defer roomData
		
		oldTrackData = this.trackData
		console.log roomData
		this.roomData = roomData.room
		this.trackData = data
		missingTracks = []
		newTracks = []
		for track in oldTrackData.tracks
			if (data.tracks.indexOf(track) == -1)
				missingTracks.push this.models.Track.fromURI("spotify:track:" + track).data
		
		for track in data.tracks
			if (oldTrackData.tracks.indexOf(track) == -1)
				newTracks.push this.models.Track.fromURI("spotify:track:" + track).data
		
		for oldTrack in missingTracks
			index = missingTracks.indexOf(oldTrack)
			newTrack = newTracks[index]
			if !oldTrack.album || !oldTrack.album.cover || !newTrack.album || !newTrack.album.cover
				continue
			target = $("div[data-id='#{oldTrack.album.cover}']")
			target.css 	"-webkit-transform", "rotate3d(1,0,0, 90deg)"
			target.attr("data-id",oldTrack.album.cover)
			rotateComplete = (target, newTrack) ->
				return () ->
					target.css 
						"-webkit-transform": "rotate3d(1,0,0, 00deg)"
						"background-image": "url(#{newTrack.album.cover})"
			
			setTimeout rotateComplete(target,newTrack),500
		
		this.setOccupants()
	
		setTimeout () =>
			console.log "hit"
			this.trackRefresh()
		,(1000 * 3)
		
	grabTrackList: (retF) =>
		await $.getJSON baseUrl + "room/" + this.roomData.id + "/tracks.json?&user[fb_id]=" + fBook.userData.id,null, defer data
		this.trackData = data
		this.playTracks()
		
		retF()
	playTracks: () =>
		if !this.playlist
			this.playlist = new this.models.Playlist()
		else if this.playlist.tracks.length == 2
			this.playlist.remove(this.playlist.tracks[1])
		targetTrack = null
		nextTrack = null
			
		if !this.trackData.room.current_track_id
			$.getJSON baseUrl + "room/" + this.roomData.id + "started.json?track_id=" + this.trackData.tracks[0] + "&user[fb_id]=" + fBook.userData.id
			targetTrack = this.trackData.tracks[0]
			nextTrack = this.trackData.tracks[1]
		else
			targetTrack = this.trackData.room.current_track_id
			nextTrack = this.trackData.tracks[0]
			
		targetTrack = this.models.Track.fromURI("spotify:track:" + targetTrack)
		nextTrack = this.models.Track.fromURI("spotify:track:" + nextTrack)
		
		if (this.playlist.tracks.length == 0)
			this.playlist.add(targetTrack)
		
		#this.playlist.add(nextTrack)
			
		this.currentTrack = targetTrack.data
		this.models.player.play targetTrack, this.playlist
		
		
	fillAlbumArt: () =>
		artTarget = $("#room .albumart")
		size =
			width: artTarget.width()
			height: artTarget.height()
		col = -1
		row = 0
		offset = 0
		
		tracks = []
		for track in this.trackData.tracks
			trackObj = this.models.Track.fromURI("spotify:track:" + track).data
			if !trackObj || !trackObj.album || !trackObj.album.cover
				continue
			if tracks.indexOf(trackObj.album.cover) == -1
				tracks.push trackObj.album.cover

		for i in [0..60]	
			col++
			if col * 200 > size.width
				col = 0
				row++
			
			x = 200 * col
			y = 200 * row
			
			if tracks.length < (i + offset + 1)
				offset -= tracks.length
			
			img = tracks[i+offset]
			zindex = i
			#if i == 31
			#	zindex = 102
			target = $("<div class='art' data-id='#{img}' style='z-index:#{zindex}; top:#{y}px; left: #{x}px'></div>")
			imgEl = new Image()
			loadedFunc = (target, imgEl) ->
				return () ->
					target.css 	"-webkit-transform", "rotate3d(1,0,0, 90deg)"
					setTimeout ()=>
						#$("img",imgtarget).css "display", "block"
						src = imgEl.src
						target.css 
							"-webkit-transform": "rotate3d(1,0,0, 00deg)"
							"background-image": "url(#{src})"
					,1000
			imgEl.onload = loadedFunc(target,imgEl)
			
			
			placeFunc = (target,imgEl,img,i) =>
				return () =>
					imgEl.src = img
					if i == 60
						setTimeout () =>
							$(".artcover").css "opacity", 1
							
						, 500
			setTimeout placeFunc(target,imgEl,img,i), (row+col) * 200
			artTarget.append target
			
	setNowPlaying: () ->
		if (!this.currentTrack || !this.currentTrack.album)
			return
		console.log this.currentTrack.album
		if this.currentTrack.album.data
			img = this.currentTrack.album.data.cover
		else
			img = this.currentTrack.album.cover
		playTarget = $("#playinfo")
		$(".currentart",playTarget).css "background-image", "url(#{img})"
		$("h3", playTarget).html this.currentTrack.name
		$("p", playTarget).html this.currentTrack.artists[0].name
		
	setOccupants:() ->
		$("#occupants ul").empty()
		data = this.roomData.users
		numToDraw = 14
		if data.length > 14
			numToDraw = 11
		
		for person in data[0...numToDraw]
			bigImg = $("<li style='background-image: url(https://graph.facebook.com/#{person.fb_id}/picture?type=large)'></li>")
			
			
			$("#occupants ul").append(bigImg)
			
		
		if data.length > 14
			more = data.length - 11
			$(".chosenby",playTarget).append("<li class='more'>(+ #{more} more)</li>")
	
window.Room = room