class brandedMap
	constructor: (target) ->
		
		target.css
			height: $(window).width() * 1.4
			width: $(window).width() * 1.4
			"margin-top": 0 - (($(window).width() - $(window).height()) / 2) - ($(window).width() * 0.2)
			"margin-left": 0 - ($(window).width() * 0.2)
			"-webkit-transform-origin": "61% 53%"
	
		this.map = new L.Map target.attr("id"),
			#center: targetLatLng
			#zoom:3
			zoomControl:false
			dragging: false
			scrollWheelZoom: false
			doubleClickZoom:false
			attributionControl: false
			
		cloudmadeUrl = 	'http://mt1.googleapis.com/vt?lyrs=m@175275956&src=apiv3&hl=en-US&x={x}&s=&y={y}&z={z}&apistyle=s.t%3A6%7Cp.s%3A-97%7Cp.v%3Aon%7Cp.l%3A100%2Cs.e%3Al%7Cp.v%3Aoff%2Cs.t%3A2%7Cp.v%3Aoff%2Cs.t%3A1%7Cp.v%3Aoff%2Cs.t%3A17%7Cs.e%3Ag%7Cp.v%3Aon%7Cp.l%3A59%2Cs.t%3A3%7Cs.e%3Ag%7Cp.v%3Asimplified%7Cp.s%3A-97%7Cp.l%3A100%2Cs.t%3A5%7Cp.s%3A-97%7Cp.l%3A-6%2Cs.t%3A4%7Cp.v%3Aoff%2Cs.t%3A51%7Cs.e%3Ag%7Cp.l%3A-20%2Cs.t%3A81%7Cp.h%3A%2388ff00%7Cp.s%3A-94%7Cp.l%3A25%7Cp.v%3Aoff&s=Gali&style=api%7Csmartmaps'
		cloudmade = new L.TileLayer(cloudmadeUrl, {maxZoom: 18});
		
		this.map.addLayer(cloudmade);
		targetLatLng = this.adjustLatLng(new L.LatLng(51.505, -0.09),3)
		
		this.map.setView targetLatLng, 3
		
		
		#marker = new L.Marker(new L.LatLng(51.505, -0.09));
		#console.log marker
		#this.map.addLayer(marker);
	
	adjustLatLng: (latlng, zoom) ->
		origin = this.map.unproject new L.Point(0,0), zoom
		destination = this.map.unproject new L.Point($(window).width() / 4,$(window).width() / 3), zoom
		shiftBy =
			lat: origin.lat - destination.lat
			lng: origin.lng - destination.lng
		
		return new L.LatLng(latlng.lat + shiftBy.lat, latlng.lng + shiftBy.lng)
		
	adjustForResults: (latlng, zoom) ->
		origin = this.map.unproject new L.Point(0,0), zoom
		
		widthDiff = $(window).width() - 460 - ($(window).width() / 2) 
		
		console.log widthDiff
		
		destination = this.map.unproject new L.Point(widthDiff,400), zoom
		shiftBy =
			lat: origin.lat - destination.lat
			lng: origin.lng - destination.lng
		console.log shiftBy
		return new L.LatLng(latlng.lat + shiftBy.lat, latlng.lng + shiftBy.lng)
		
		
		
window.BrandedMap = brandedMap