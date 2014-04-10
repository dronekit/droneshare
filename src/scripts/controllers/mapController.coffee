class Controller
	constructor: (@$scope) ->
		defaults:
			scrollWheelZoom: false

angular.module('app').controller 'mapController', ['$scope', Controller]

###
app.controller("SimpleMapController", [ '$scope', function($scope) {
    angular.extend($scope, {
        defaults: {
            scrollWheelZoom: false
        }
    });
}]);
###