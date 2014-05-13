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

class BoundsFactory
  constructor: () ->
    @bounds =
      northEast:
        lat: -Number.MAX_VALUE
        lng: -Number.MAX_VALUE
      southWest:
        lat: Number.MAX_VALUE
        lng: Number.MAX_VALUE

  # expand bounding box to include pt
  # returns true if we changed the bounding box
  expand: (lat, lon) ->
    # Updating bounds are _very_ expensive in leaflet, so we try to 'bucket' our bounds in .1 deg increments
    roundUp = (x) -> Math.ceil(x * 10) / 10.0
    roundDown = (x) -> Math.floor(x * 10) / 10.0

    dirty = false

    # We use the dirty flag to avoid changing scope object if nothing changed
    min = (newval, old) ->
      if newval < old
        dirty = true
        newval
      else
        old

    max = (newval, old) ->
      if newval > old
        dirty = true
        newval
      else
        old

    @bounds.southWest.lat = min(roundDown(lat),@bounds.southWest.lat)
    @bounds.southWest.lng = min(roundDown(lon), @bounds.southWest.lng)
    @bounds.northEast.lat = max(roundUp(lat), @bounds.northEast.lat)
    @bounds.northEast.lng = max(roundUp(lon), @bounds.northEast.lng)
    dirty

class LiveMapController extends MapController
  @$inject: ['$scope', '$log', 'leafletData', '$http', 'missionService']
  constructor: (scope, @log, leafletData, http, @missionService) ->
    scope.leafletData = leafletData
    @boundsFactory = new BoundsFactory

    @count = 0
    scope.vehicleMarkers = {}
    scope.vehiclePaths = {}
    scope.bounds = {} # Angular wants to see at least an empty object (not undefined)
    scope.center = {}

    # TODO: fake markers arn't workng
    #scope.vehicleMarkers['missionId_fake'] = {lat: scope.hawaii.lat, lng: scope.hawwai.lng, focus: false, draggable: false}

    super(scope, http)

    # FIXME - Ramon, why is service now one level nested in @missionService?
    s = @missionService.service

    listeners =
      "loc": @onLive
      "att": @onAttitude
      "start": @onMissionStart
      "end": @onMissionEnd
      "mode": @updateVehicleMessage
      "arm": @updateVehicleMessage
      "mystery": @updateVehicleMessage
      "text": @updateVehicleMessage

    listenerIds = s.atmosphere.on(name, callback) for name, callback of listeners
    @log.debug('live map now subscribed')

    # We bounce our atmosphere link, because the server will automatically resend vehicle messages on each new connection
    # (And our controller is not keeping a list of past connection messages - FIXME, it would be better to keep
    # a model object to preserve such state)
    s.atmosphere_connect()

    scope.$on("$destroy", () =>
        @log.debug('Unsubscribe for atmosphere notification')
        for id of listenerIds
          s.atmosphere.off(id)
        s.atmosphere_disconnect()
    )

  onLive: (data) =>
    # FIXME - not sure if I need apply... (or how to optimize it)
    # Apply should be called around the function to be guarded... -kevinh
    @scope.$apply(() =>
      key = @vehicleKey(data.missionId)
      @updateVehicle(key, data)

      # Grow (or create) our bounds
      if @boundsFactory.expand(data.payload.lat, data.payload.lon)
        @scope.bounds = @boundsFactory.bounds
    )

  onAttitude: (data) =>
    # FIXME - not sure if I need apply... (or how to optimize it)
    # Apply should be called around the function to be guarded... -kevinh
    @scope.$apply(() =>
      key = @vehicleKey(data.missionId)
      v = @scope.vehicleMarkers[key]
      if v? # We only update heading if we already have an object with position
        v.iconAngle = data.payload.yaw
        # oops - angular-leaflet only reads options at the time the marker is created, either we need to manage our own
        # markers (probably a good idea) or we need to recreate the marker to get the new heading to show up.
        #@log.debug("Can't set angle to #{v.iconAngle} because angular-leaflet is dumb and separates options from markers")
    )

  onMissionStart: (data) ->
    # creating empty markers is bad - causes null ref in leaflet
    # @scope.vehicleMarkers[@vehicleKey(data.missionId)] ?= {}

  onMissionEnd: (data) =>
    vehicleKey = @vehicleKey(data.missionId)
    delete @scope.vehicleMarkers[vehicleKey]
    delete @scope.vehiclePaths[vehicleKey]

  updateVehicle: (vehicleKey, data) =>
    # We don't add new vehicles to the hashtable until fully inited (because I think angular has hooks watching for writes to @scope)
    v = @scope.vehicleMarkers[vehicleKey] ? {}
    v.lat = data.payload.lat
    v.lng = data.payload.lon
    v.focus = false
    v.draggable = false
    # TODO: icons need to be better
    # direction of arrow on icon should change depending on direction
    v.icon =
        iconUrl: 'images/vehicle-marker.png'
        iconSize: [35, 35] #size of the icon
        iconAnchor: [17.5, 17.5] # point of the icon which will correspond to marker's location
        popupAnchor: [0, -17.5] # point from which the popup should open relative to the inconAnchor
    @scope.vehicleMarkers[vehicleKey] = v
    @motionTracking(vehicleKey, {lat: data.payload.lat, lng: data.payload.lon})

  updateVehicleMessage: (data) =>
    # TODO: its really ugly and its doing nothing
    # (kevinh - if we receive a message before we know the vehicle loc just drop it because having a marker without a loc freaks out leaflet)
    vehicleKey = @vehicleKey(data.missionId)
    if @scope.vehicleMarkers[vehicleKey]?
      @scope.vehicleMarkers[vehicleKey].message ?= "lat: #{@scope.vehicleMarkers[vehicleKey].lat} - lon: #{@scope.vehicleMarkers[vehicleKey].lng} - #{JSON.stringify(data.payload)}"

  motionTracking: (vehicleKey, latlng) =>
    v = @scope.vehiclePaths[vehicleKey] ? { color: '#f76944', weight: 7, latlngs: []}
    v.latlngs.push(latlng)
    @scope.vehiclePaths[vehicleKey] = v

  vehicleKey: (vehicleId) ->
    "missionId_#{vehicleId}"

angular.module('app').controller 'mapController', MapController
angular.module('app').controller 'liveMapController', LiveMapController
