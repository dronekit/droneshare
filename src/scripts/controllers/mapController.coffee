

angular.module('app').controller 'mapController', ['$scope', ($scope) =>
	# Collect various maps worth using
	maps =
		openstreetmap:
        	url: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        	options:
            	attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        opencyclemap:
            url: "http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png",
            options:
                attribution: 'All maps &copy; <a href="http://www.opencyclemap.org">OpenCycleMap</a>, map data &copy; <a href="http://www.openstreetmap.org">OpenStreetMap</a> (<a href="http://www.openstreetmap.org/copyright">ODbL</a>'
        mapbox_bright:
        	url: "https://a.tiles.mapbox.com/v3/mapbox.world-bright/{z}/{x}/{y}.png"
        mapbox_example:
        	url: "https://a.tiles.mapbox.com/v3/examples.map-zr0njcqy/{z}/{x}/{y}.png"
        threedr_default:
        	url: "https://a.tiles.mapbox.com/v3/kevin3dr.hokdl9ko/{z}/{x}/{y}.png"


	angular.extend $scope,
		defaults:
			scrollWheelZoom: true
		tiles: maps.threedr_default
		london:
            lat: 51.505
            lng: -0.09
            zoom: 8

	]

###
app.controller("SimpleMapController", [ '$scope', function($scope) {
    angular.extend($scope, {
        defaults: {
            scrollWheelZoom: false
        }
    });
}]);
###