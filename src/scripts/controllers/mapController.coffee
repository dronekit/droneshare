# FIXME - fetch kml from here http://localhost:8080/api/v1/mission/10/messages.kml
class MapController
  @$inject: ['$scope', '$http']
  constructor: (@scope, @http) ->
    @initMap()

  initMap: =>
    # Collect various maps worth using
    mbox = (key) ->
      url: "https://a.tiles.mapbox.com/v3/" + key + "/{z}/{x}/{y}.png"
      options:
        attribution: '<a href="http://www.mapbox.com/about/maps/" target="_blank">Terms &amp; Feedback</a>'

    maps =
      openstreetmap:
        url: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        options:
          attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      opencyclemap:
        url: "http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png",
        options:
          attribution: 'All maps &copy; <a href="http://www.opencyclemap.org">OpenCycleMap</a>, map data &copy; <a href="http://www.openstreetmap.org">OpenStreetMap</a> (<a href="http://www.openstreetmap.org/copyright">ODbL</a>'
      mapbox_bright: mbox("mapbox.world-bright")
      mapbox_example: mbox("examples.map-zr0njcqy")
      threedr_default: mbox("kevin3dr.hokdl9ko")

    @scope.defaults =
      scrollWheelZoom: true
      zoom: 10
    @scope.tiles = maps.threedr_default

class LiveMapController extends MapController
  @$inject: ['$scope', '$http', 'missionService']
  constructor: (scope, http, @missionService) ->
    scope.vehicleMarkers = {}
    scope.vehiclePaths = {}
    scope.center =
      lat: 19.4284700
      lng: -99.1276600
      zoom: 3
    # TODO: fix how we get initial bounds and how we center the map
    # right now it's hard fixed to hawaii since bot gives
    # every mission around the area

    # TODO: fake markers arn't workng
    #scope.vehicleMarkers['missionId_fake'] = {lat: scope.hawaii.lat, lng: scope.hawwai.lng, focus: false, draggable: false}

    super(scope, http)

    @missionService.atmosphere.on("loc", @onLive)
    @missionService.atmosphere.on("start", @onMissionStart)
    @missionService.atmosphere.on("end", @onMissionEnd)
    @missionService.atmosphere.on("mode", @updateVehicleMessage)
    @missionService.atmosphere.on("arm", @updateVehicleMessage)
    @missionService.atmosphere.on("mystery", @updateVehicleMessage)
    @missionService.atmosphere.on("text", @updateVehicleMessage)

  onLive: (data) =>
    @scope.vehicleMarkers["missionId_#{data.missionId}"] ?= {}
    @updateVehicle(@vehicleKey(data.missionId), data)

    @scope.bounds.push [data.payload.lat, data.payload.lon]

    # FIXME - not sure if I need apply... (or how to optimize it)
    @scope.$apply()

  onMissionStart: (data) =>
    @scope.vehicleMarkers[@vehicleKey(data.missionId)] ?= {}

  onMissionEnd: (data) =>
    vehicleKey = @vehicleKey(data.missionId)
    delete @scope.vehicleMarkers[vehicleKey]
    delete @scope.vehiclePaths[vehicleKey]

  updateVehicle: (vehicleKey, data) =>
    if data.payload.lat and data.payload.lat
      @scope.vehicleMarkers[vehicleKey].lat = data.payload.lat
      @scope.vehicleMarkers[vehicleKey].lng = data.payload.lon
      @scope.vehicleMarkers[vehicleKey].focus = false
      @scope.vehicleMarkers[vehicleKey].draggable = false
      # TODO: icons need to be better
      # direction of arrow on icon should change depending on direction
      @scope.vehicleMarkers[vehicleKey].icon =
          iconUrl: 'images/vehicle-marker.png'
          iconSize: [35, 35] #size of the icon
          iconAnchor: [17.5, 17.5] # point of the icon which will correspond to marker's location
          popupAnchor: [0, -17.5] # point from which the popup should open relative to the inconAnchor
      @motionTracking(vehicleKey, {lat: data.payload.lat, lng: data.payload.lon})

  updateVehicleMessage: (data) =>
    # TODO: its really ugly and its doing nothing
    vehicleKey = @vehicleKey(data.missionId)
    @scope.vehicleMarkers[vehicleKey] ?= {}
    @scope.vehicleMarkers[vehicleKey].message ?= "lat: #{@scope.vehicleMarkers[vehicleKey].lat} - lon: #{@scope.vehicleMarkers[vehicleKey].lng} - #{JSON.stringify(data.payload)}"

  motionTracking: (vehicleKey, latlng) =>
    @scope.vehiclePaths[vehicleKey] ?= { color: '#f76944', weight: 7, latlngs: []}
    @scope.vehiclePaths[vehicleKey].latlngs.push(latlng)

  vehicleKey: (vehicleId) =>
    "missionId_#{vehicleId}"

angular.module('app').controller 'mapController', MapController
angular.module('app').controller 'liveMapController', LiveMapController
