class frontPage
	userLocation: null
	savedLocations: []
	constructor: () ->
		self = this
		await $.getJSON baseUrl+"me.json?user[fb_id]=" + fBook.userData.id, defer data
		if data == null
			url = "users/new?user[fb][access_token]={1}&user[fb][key]={2}&user[fb][token_expires_at]={3}"
				.replace("{1}",fBook.accessToken)
				.replace("{2}",fBook.userData.id)
				.replace("{3}",fBook.timeToExpiry)
			
			data = 
				"user[fb][access_token]": fBook.accessToken
				"&user[fb][key]":fBook.userData.id
				"user[fb][token_expires_at]": fBook.timeToExpiry
			
				
			await $.post baseUrl+"users",data, defer data
			console.log data
				
#			await $.getJSON baseUrl+url, defer data
			
		if data.room_id
			console.log "joining"
			#this.joinRoom data.room_id, true
			#return;
			
		$("#listenSearch").css "display", "block"	
			
		this.map = new BrandedMap($("#frontpageMap"))
		$("#txtLocation").bind "keyup", () ->
			self.locationKeyPress(this)
		this.setTrendingLocations trendingLocations
		
		doLocation = () =>
			await fBook.doRequest "me/?fields=location", defer data
			if data.location
				await fBook.doRequest "/" + data.location.id, defer data
				this.userLocation =
					lat: data.location.latitude
					lng: data.location.longitude
		doLocation()
		
		$("#olSearch, #olTrending").delegate "li", "click", () ->
			self.locationClicked this
		
		$("#btnJoinRoom").click ()=>
			self.joinRoom this.currentRoom.id
		
		$("#btnBack").click this.backClicked
		
		$(window).bind "resize", this.onResize
		this.onResize()
	onResize: () ->
		offset = $("#divTrending").offset()
		$("#olTrending, #olSearch").css
			height: $(window).height() - offset.top - 30
	locationKeyPress: (el) ->
		if $(el).val().length < 3
			$("#divTrending").show()
			$("#divSearch").hide()
			return
		
		searchUrl = baseUrl + "room/find.json?q=" + $(el).val() + "&user[fb_id]=" + fBook.userData.id
		if (this.userLocation)
			searchUrl += "&center=" + this.userLocation.lat + "," + this.userLocation.lng
		rightNow = new Date().valueOf()
		#this.lastDateDisplayed = rightNow
		completeFunc = (dateSent) =>
			return (data) =>
				if this.lastDateDisplayed && this.lastDateDisplayed > dateSent
					return
				this.lastDateDisplayed = dateSent
		
				this.setSearchLocations data.rooms
				nameArray = for loc in data.rooms
					if !this.savedLocations[loc.fb_id]
						this.savedLocations[loc.fb_id] = loc
					loc
		if this.currentKeyTimer
			clearTimeout(this.currentKeyTimer)			
		this.currentKeyTimer = setTimeout () ->			
			$.getJSON searchUrl,null,completeFunc(rightNow)
		, 500
	backClicked:() =>
		$("#frontpageMap").css "-webkit-transform", "rotate(-15deg)"
		targetLatLng = this.map.adjustLatLng(new L.LatLng(51.505, -0.09),3)
		this.map.map.removeLayer this.currentmarker
		this.map.map.setView targetLatLng, 3
		$("#roomdetails").css "right", -527
		
	locationClicked: (el) ->
		loc = this.savedLocations[$(el).attr("data-id")]
		targetLatLng = new L.LatLng(loc.location.latitude, loc.location.longitude)
		
		this.map.map.setView this.map.adjustForResults(targetLatLng,12), 12
		
		$("#frontpageMap").css "-webkit-transform", "rotate(0deg)"
		this.map.map.setView this.map.adjustForResults(targetLatLng,12), 12
		
		
		if this.currentmarker
			this.map.map.removeLayer(this.currentmarker)
			$("#roomdetails").css "right", -527
			
		this.currentmarker = new L.Marker(targetLatLng);
		#console.log marker
		this.map.map.addLayer(this.currentmarker);
		this.getRoomDetails loc.fb_id

	getRoomDetails: (locid) =>
		this.downloadRoom locid, (data) =>
			divs = []
			this.currentRoom = data
			$("#roomdetails div.art").remove()
			for i in [0..7]
				art = getRandomArtwork().replace("_200","_100")
				divs.push "<div class='art' style='background-image:url(#{art})'/>"
				
			$("#roomdetails .roomart").append(divs.join(""))
			$("#roomdetails h1").html(data.name)
			
		$("#roomdetails").css "right", 0
		
		
		
	downloadRoom: (locid, retFunc) =>
		
		retFunc(this.savedLocations[locid])
		
	joinRoom: (roomid,instant) ->
		$.getJSON baseUrl + "room/join.json?room_id=" + roomid + "&user[fb_id]=" + fBook.userData.id, null, (ret) =>
			console.log ret
			if instant
				new Room(ret)
			else
				setTimeout () ->
					new Room(ret)
				,500
		if !instant
			this.map.map.removeLayer this.currentmarker
			$("#roomdetails").css "right", -527
			$("#listenSearch").css "left", -460
			$("#frontpageMap").css "-webkit-transform", "scale(80)"
		
		
	
	setSearchLocations: (locs) ->
		$("#olSearch").empty()
		$("#divTrending").hide()
		$("#divSearch").show()
		for loc in locs
			console.log loc
			li = $("<li data-id='#{loc.fb_id}'/>")
			
			locString = ""
			if loc.location.street
				locString = loc.location.street
			if !loc.location.city
				continue
			li.append("<h4 class='loctitle'>#{loc.name}<span>, #{locString}</span></h4>")
			li.append("<p>#{loc.location.city}, #{loc.location.country}</p>")
			$("#olSearch").append(li)
	
	setTrendingLocations: (locs) ->
		for locid,loc of locs
			this.savedLocations[locid] = loc
			li = $("<li data-id='#{locid}'/>")
			
			artwork = $("<div class='albumart'/>")
			for i in [0..3]
				imgUrl = getRandomArtwork().replace("_200.jpg","_50.jpg")
				imgSrc = "<img src='#{imgUrl}'/>"
				artwork.append imgSrc
			
			li.append artwork
			
			li.append "<h4 class='loctitle'>#{loc.name}<span>, #{loc.location.city}</span></h4>";
			numInRoom = Math.round(Math.random() * 50);
			peopleDiv = $("<div class='numpeople'><p>#{numInRoom} people</p></div>")
			
			await getRandomPeople 9, defer people
			
			peopleAdded = 0
			for person in people
				peopleAdded++
				if (peopleAdded > numInRoom)
					break
				if !person
					continue
				peopleDiv.append "<img src='#{person.picture}'/>"
			
			if (peopleAdded < numInRoom)
				peopleDiv.append("<p>(+#{numInRoom - 10} more)")
			
			li.append peopleDiv
			
			$("#olTrending").append(li)
		
trendingLocations =
	1:
		id: 1
		fb_id: 1
		location:
			latitude: 51.54528
			longitude: 0.00444
			city: "London, UK"
		name: "Olympics Aquatic Centre"
		users:[
			id: "4f89f09f2f28e61091000001",
			fb_id: "509108009",
			last_room_action_at: "2012-04-15T14:49:00Z",
			first_name: null,
			last_name: null,
			weight: 1
		]
	,
	2:
		id:2
		fb_id:2
		location:
			latitude: 51.54528
			longitude: 0.00444
			city: "London, UK"
		name: "Olympics Stadium"


window.getRandomPeople = (num, retFunc) ->
	await fBook.getFriends defer friends
	retArray = []
	while retArray.length < num
		rand = Math.round(Math.random() * friends.length)
		retArray.push(friends[rand])
	retFunc(retArray)

window.getRandomArtwork = () ->
	rand = Math.round(Math.random() * dummyArtwork.length);
	return dummyArtwork[rand]

dummyArtwork = [
	"http://cdn.7static.com/static/img/sleeveart/00/003/865/0000386518_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/013/621/0001362119_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/006/970/0000697091_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/012/291/0001229189_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/012/583/0001258320_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/002/118/0000211849_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/003/912/0000391287_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/653/0001065372_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/649/0001064932_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/652/0001065222_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059073_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/635/0001063527_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058978_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059073_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058967_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058926_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/008/516/0000851676_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/398/0000039895_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/398/0000039895_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/005/768/0000576858_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059073_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058967_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058926_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058978_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058978_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/312/0000031237_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/454/0000045472_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058926_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/014/927/0001492721_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/654/0001065473_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/005/502/0000550241_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431292_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431297_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405065_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/009/0000000975_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431297_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/010/0000001036_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/005/502/0000550245_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/005/502/0000550245_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/005/0000000575_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/011/931/0001193196_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431297_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431292_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/004/878/0000487877_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059034_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/242/0000024279_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/007/443/0000744308_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/367/0000036753_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/101/0000010162_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/005/333/0000533382_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/005/608/0000560871_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/002/790/0000279046_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/842/0001084277_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/000/102/0000010254_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/013/928/0001392819_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/003/394/0000339455_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059003_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058967_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059003_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/006/354/0000635406_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/006/354/0000635406_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/006/354/0000635406_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/654/0001065473_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/654/0001065460_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059003_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/008/203/0000820329_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/008/203/0000820329_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/008/203/0000820329_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/008/203/0000820329_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/005/753/0000575307_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/014/833/0001483374_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059003_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg"
	"http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059073_200.jpg"
	
	]
	
window.FrontPage = frontPage