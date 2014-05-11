angular.module('app').directive 'recentFlights', ['$window', ($window) -> return {
  restrict: 'E'
  controller: ($scope, element) ->
    console.log('++ controller ', $scope)
  templateUrl: '/views/directives/recent-flights.html'
  compile: (element, attributes) ->
    pre: ($scope, element, attributes, controller) ->
      console.log('++ pre ', $scope)
    post: ($scope, element, attributes, controller) ->
      console.log('++ post/link ', $scope)
}]



