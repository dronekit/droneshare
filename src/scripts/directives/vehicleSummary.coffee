angular.module('app').directive 'vehicleSummary', ['$window', ($window) ->
  restrict: 'E'
  templateUrl: '/views/directives/vehicle-summary.html'
  scope:
    vehicle: '='
]
