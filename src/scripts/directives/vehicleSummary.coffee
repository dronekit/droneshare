angular.module('app').directive 'vehicleSummary', ['$window', ($window) -> return {
  restrict: 'E'
  templateUrl: '/views/directives/vehicle-summary.html'
  scope: 
    vehicle: '='
}]