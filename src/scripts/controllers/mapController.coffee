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
      minZoom: 2
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
  @$inject: ['$scope', '$log', 'leafletData', '$http', 'missionService', 'authService']
  constructor: (scope, @log, leafletData, http, @missionService, @authService) ->
    scope.leafletData = leafletData
    @boundsFactory = new BoundsFactory

    @count = 0
    scope.vehicleMarkers = {}
    scope.vehiclePaths = {}
    scope.bounds = {} # Angular wants to see at least an empty object (not undefined)
    scope.center = {}

    # I think angular will notify me if login changes
    scope.user = authService.getUser()
    scope.$watch 'user', () =>
      @log.info("Restarting atmosphere due to username change")
      @disconnectAtmo()
      @connectAtmo()

    super(scope, http)

    @connectAtmo()

    # If we get destroyed teardown our connections
    scope.$on("$destroy", () => @disconnectAtmo)

  onLive: (data) =>
    # Apply should be called around the function to be guarded... -kevinh
    @scope.$apply () =>
      key = @vehicleKey(data.missionId)
      @updateVehicle(key, data.payload.lat, data.payload.lon)

      # Grow (or create) our bounds - We don't really use this feature much any more because starting with the whole world looks better
      #if @boundsFactory.expand(data.payload.lat, data.payload.lon)
      #  @scope.bounds = @boundsFactory.bounds

  connectAtmo: =>
    @log.debug('live map now subscribed')
    listeners =
      "loc": @onLive
      "att": @onAttitude
      "start": @onMissionUpdate
      "end": @onMissionEnd
      "mode": @updateVehicleMessage
      "arm": @updateVehicleMessage
      "update": @onMissionUpdate
      "user": @onMissionUpdate
      "mystery": @updateVehicleMessage
      "text": @updateVehicleMessage

    s = @missionService
    @listenerIds = s.atmosphere.on(name, callback) for name, callback of listeners
    s.atmosphere_connect()

  disconnectAtmo: =>
    @log.debug('Unsubscribe for atmosphere notification')
    s = @missionService
    for id of @listenerIds
      s.atmosphere.off(id)
    s.atmosphere_disconnect()

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

  onMissionUpdate: (data) =>
    @scope.$apply(() =>
      key = @vehicleKey(data.missionId)
      payload = data.payload
      lat = payload.latitude
      lon = payload.longitude
      if lat? && lon?
        v = @updateVehicle(key, lat, lon, payload)
        @updateMarkerPopup(v, payload)
    )

  onMissionEnd: (data) =>
    vehicleKey = @vehicleKey(data.missionId)
    delete @scope.vehicleMarkers[vehicleKey]
    delete @scope.vehiclePaths[vehicleKey]

  # Returns the marker
  updateVehicle: (vehicleKey, lat, lon, newMission) =>
    # We don't add new vehicles to the hashtable until fully inited (because I think angular has hooks watching for writes to @scope)
    v = @scope.vehicleMarkers[vehicleKey] ? {}

    v.payload ?= {} # Provide a placeholder empty set of payload fields
    if newMission? # If we have a new mission use it to extend our payload
      angular.extend(v.payload, newMission)

    v.lat = lat
    v.lng = lon
    v.focus = false
    v.draggable = false
    mission = v.payload
    isLive = mission?.isLive ? true # If we haven't yet received the mission object assume live
    # direction of arrow on icon should change depending on direction

    loginName = @authService.getUser()?.login
    isMine = loginName == mission?.userName
    @log.debug("#{mission?.userName} #{mission?.id} vs #{loginName} isMine=#{isMine}")
    v.icon =
        iconUrl:
          if isMine
            mission.userAvatarImage + '?d=mm'
          else if isLive
            'images/vehicle-marker-active.png'
          else
            'images/vehicle-marker-inactive.png'
        iconSize: [35, 35] #size of the icon
        iconAnchor: [17.5, 17.5] # point of the icon which will correspond to marker's location
        popupAnchor: [0, -17.5] # point from which the popup should open relative to the inconAnchor

    if isMine # Show rounded corners on avatar icons
      v.icon.className = "img-rounded"

    @scope.vehicleMarkers[vehicleKey] = v
    @motionTracking(vehicleKey, {lat: lat, lng: lon})
    v

  updateVehicleMessage: (data) =>
    @scope.$apply(() =>
      # TODO: its really ugly and its doing nothing
      # (kevinh - if we receive a message before we know the vehicle loc just drop it because having a marker without a loc freaks out leaflet)
      vehicleKey = @vehicleKey(data.missionId)
      marker = @scope.vehicleMarkers[vehicleKey]
      @updateMarkerPopup(marker, data.payload)
    )

  # Change our popup text as needed
  updateMarkerPopup: (marker, payload) ->
    if marker?
      # We merge the misc payload fields into one dictionary - showing the latest combination of all data
      angular.extend(marker.payload, payload)
      p = marker.payload
      if p.userName? && p.id? && p.summaryText?
        marker.message = """
          <!-- Two columns -->
          <table id="map-info-popup">
            <tr>
              <td>
                <img src="#{p.userAvatarImage}?s=40&d=mm"></img>
              </td>

              <td>
                <a href='/user/#{p.userName}'>#{p.userName}</a><br>
                <a href='/mission/#{p.id}'>#{p.summaryText}</a><br>
                #{Math.round(p.flightDuration / 60)} minutes<br>
              </td>
            </tr>
          </table>
          """

  motionTracking: (vehicleKey, latlng) =>
    v = @scope.vehiclePaths[vehicleKey] ? { color: '#f76944', weight: 7, latlngs: []}

    # Only keep the last 100 pts around
    v.latlngs = v.latlngs[..99]
    v.latlngs.push(latlng)
    @scope.vehiclePaths[vehicleKey] = v

  vehicleKey: (vehicleId) ->
    "missionId_#{vehicleId}"

angular.module('app').controller 'mapController', MapController
angular.module('app').controller 'liveMapController', LiveMapController
