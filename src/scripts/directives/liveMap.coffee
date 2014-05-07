angular.module('app').directive 'liveMap', ['$window', ($window) -> return {
  restrict: 'E'
  transclude: true
  controller: ($scope, leafletData) ->
    $scope.leafletData = leafletData
    $scope.ui_bounds = $('#main-navigation').height() + $('#footer').height()
    $scope.initializeWindowSize = ->
      $scope.windowHeight =  $window.innerHeight - ( $scope.ui_bounds )
      $scope.leafletData.getMap().then (map) ->
        map.invalidateSize(false)
  template: '<leaflet watchMarkers defaults="defaults" center="center" bounds="bounds" markers="vehicleMarkers" paths="vehiclePaths" tiles="tiles" height="{{windowHeight}}" width="100%"></leaflet>'
  compile: (element, attributes) ->
    pre: ($scope, element, attrs) ->
      $scope.initializeWindowSize()
      angular.element($window).bind 'resize', ->
        $scope.initializeWindowSize()
        $scope.$apply()
}]
