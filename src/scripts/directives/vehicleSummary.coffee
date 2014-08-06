angular.module('app').directive 'vehicleSummary', ['$window', ($window) ->
  restrict: 'A'
  templateUrl: '/views/directives/vehicle-summary.html'
  controller: 'vehicleController as controller'
  scope:
    vehicle: '='
]
