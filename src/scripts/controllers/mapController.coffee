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

    @scope.defaults = scrollWheelZoom: true
    @scope.tiles = maps.threedr_default

class LiveMapController extends MapController
  @$inject: ['$scope', '$http', 'missionService']
  constructor: (scope, http, @missionService) ->
    scope.vehicleMarkers = {}
    # TODO: fix how we get initial bounds and how we center the map
    # right now it's hard fixed to hawaii since bot gives
    # every mission around the area
    scope.bounds = [[21.4858041, -157.5735364]]
    scope.hawaii =
      lat: 21.4858041,
      lng: -157.5735364,
      zoom: 10

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
    @updateVehicle("missionId_#{data.missionId}", data)

    @scope.bounds.push [data.payload.lat, data.payload.lon]

    # FIXME - not sure if I need apply... (or how to optimize it)
    @scope.$apply()

  onMissionStart: (data) =>
    @scope.vehicleMarkers["missionId_#{data.missionId}"] ?= {}

  onMissionEnd: (data) =>
    delete @scope.vehicleMarkers["missionId_#{data.missionId}"]

  updateVehicle: (vehicleId, data) =>
    @scope.vehicleMarkers["missionId_#{data.missionId}"].lat = data.payload.lat
    @scope.vehicleMarkers["missionId_#{data.missionId}"].lng = data.payload.lon
    @scope.vehicleMarkers["missionId_#{data.missionId}"].focus = false
    @scope.vehicleMarkers["missionId_#{data.missionId}"].draggable = false
    # TODO: icons need to be better
    @scope.vehicleMarkers["missionId_#{data.missionId}"].icon =
        iconUrl: 'images/vehicle-marker.png'
        iconSize: [35, 35] #size of the icon
        iconAnchor: [17, 34] # point of the icon which will correspond to marker's location
        popupAnchor: [-5, -5] # point from which the popup should open relative to the inconAnchor
        shadowSize: [35, 35] # size of the shadow
        shadowAnchor: [17, 34] # point of the shadow which will correspont to the markers location

  updateVehicleMessage: (data) =>
    # TODO: its really ugly and its doing nothing
    @scope.vehicleMarkers["missionId_#{data.missionId}"] ?= {}
    vehicle = @scope.vehicleMarkers["missionId_#{data.missionId}"]
    @scope.vehicleMarkers["missionId_#{data.missionId}"].message ?= "lat: #{vehicle.lat} - lon: #{vehicle.lng} - #{JSON.stringify(data.payload)}"

angular.module('app').controller 'mapController', MapController
angular.module('app').controller 'liveMapController', LiveMapController
