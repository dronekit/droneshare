(function() {
  angular.module('app').directive('mapboxStaticMap', function() {
    return {
      restrict: 'A',
      template: '<img ng-src="{{url}}"></img>',
      scope: {
        latitude: '=',
        longitude: '=',
        width: '=',
        height: '=',
        zoom: '=?',
        icon: '=?',
        color: '=?'
      },
      controller: [
        "$scope", function(scope) {
          var apikey, color, latitude, latlonstr, longitude, markerstr, zoom, _ref, _ref1;
          apikey = 'kevin3dr.hokdl9ko';
          longitude = scope.longitude;
          latitude = scope.latitude;
          zoom = (_ref = scope.zoom) != null ? _ref : "8";
          latlonstr = "" + longitude + "," + latitude + "," + zoom;
          markerstr = scope.icon != null ? (color = (_ref1 = scope.color) != null ? _ref1 : "f44", "pin-s-" + scope.icon + "+" + color + "(" + latlonstr + ")/") : "";
          return scope.url = "http://api.tiles.mapbox.com/v3/" + apikey + "/" + markerstr + latlonstr + "/" + scope.width + "x" + scope.height + ".png";
        }
      ]
    };
  });

}).call(this);
