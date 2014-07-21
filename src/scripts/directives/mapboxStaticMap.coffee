angular.module('app').directive 'mapboxStaticMap', () ->
  restrict: 'A'
  template: '<img ng-src="{{url}}"></img>'
  scope:
    latitude: '='
    longitude: '='
    width: '='
    height: '='
    zoom: '=?'
    icon: '=?' # A mapbox icon name string
    color: '=?' # html hex color string
  controller: [ "$scope", (scope) ->
    apikey = 'kevin3dr.hokdl9ko' # FIXME - move this someplace better

    longitude = scope.longitude
    latitude = scope.latitude
    zoom = scope.zoom ? "10"
    latlonstr = "#{longitude},#{latitude},#{zoom}"
    markerstr = if scope.icon?
      color = scope.color ? "f44" # default to redish
      "pin-s-#{scope.icon}+#{color}(#{latlonstr})/"
    else
      ""
    scope.url = "http://api.tiles.mapbox.com/v3/#{apikey}/#{markerstr}#{latlonstr}/#{scope.width}x#{scope.height}.png"
  ]
