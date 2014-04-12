

# FIXME - fetch kml from here http://localhost:8080/api/v1/mission/10/messages.kml
class Controller
  @$inject: ['$scope', '$http']
  constructor: (@scope, @http) ->
    @initMap()

  initMap: =>
    # Collect various maps worth using
    mbox = (key) ->
      url: "https://a.tiles.mapbox.com/v3/" + key + "/{z}/{x}/{y}.png"
      options: attribution: '<a href="http://www.mapbox.com/about/maps/" target="_blank">Terms &amp; Feedback</a>'

    maps =
      openstreetmap:
        url: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        options: attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      opencyclemap:
        url: "http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png",
        options: attribution: 'All maps &copy; <a href="http://www.opencyclemap.org">OpenCycleMap</a>, map data &copy; <a href="http://www.openstreetmap.org">OpenStreetMap</a> (<a href="http://www.openstreetmap.org/copyright">ODbL</a>'
      mapbox_bright: mbox("mapbox.world-bright")
      mapbox_example: mbox("examples.map-zr0njcqy")
      threedr_default: mbox("kevin3dr.hokdl9ko")

    console.log("Extending angular " + @scope)
    @scope.defaults = scrollWheelZoom: true
    @scope.tiles = maps.threedr_default
    @scope.london =
      lat: 51.505
      lng: -0.09
      zoom: 8

angular.module('app').controller 'mapController', Controller
