angular.module('app').directive 'liveMap', ['$window', ($window) -> return {
  restrict: 'E'
  transclude: true
  controller: 'liveMapController'
  templateUrl: '/views/directives/live-map.html'
  compile: (element, attributes) ->
    pre: ($scope, element, attrs) ->
      $scope.ui_bounds = $('#main-navigation').height() + $('#footer').height()
      $scope.initializeWindowSize = ->
        $scope.windowHeight = $window.innerHeight - ( $scope.ui_bounds )
        $scope.windowWidth = $window.innerWidth

        $scope.leafletData.getMap().then (map) ->
          $(map._container).css
            height: "#{$scope.windowHeight}px"
            width: "#{$scope.windowWidth}px"
          map.invalidateSize(false)
      angular.element($window).bind 'resize', ->
        $scope.initializeWindowSize()
        $scope.$apply()
      $scope.initializeWindowSize()
}]
