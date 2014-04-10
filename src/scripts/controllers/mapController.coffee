

angular.module('app').controller 'mapController', ['$scope', ($scope) =>
	angular.extend $scope,
		defaults:
			scrollWheelZoom: true
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