(function() {
  angular.module('app').directive('vehicleSummary', [
    '$window', function($window) {
      return {
        restrict: 'A',
        templateUrl: '/views/directives/vehicle-summary.html',
        controller: 'vehicleController as controller',
        scope: {
          vehicle: '='
        }
      };
    }
  ]);

}).call(this);
