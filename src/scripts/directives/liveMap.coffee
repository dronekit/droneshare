angular.module('app').directive 'liveMap', ['$window', ($window) -> return {
  restrict: 'A'
  transclude: true
  controller: 'liveMapController'
  templateUrl: '/views/directives/live-map.html'
  link: ($scope, $element, attrs) ->
    sameRouteSameParams = (config) -> $scope.urlBase == config.url

    $scope.$on 'loading-started', (event, config) ->
      $scope.recordsLoaded(false, config) if sameRouteSameParams(config)
    $scope.$on 'loading-complete', (event, config) ->
      $scope.recordsLoaded(true, config) if sameRouteSameParams(config)

    $scope.uiBounds = $('#main-navigation').height() + $('#footer').height()
    $scope.initializeWindowSize = ->
      $scope.windowHeight = $window.innerHeight - ( $scope.uiBounds )

      $scope.leafletData.getMap().then (map) ->
        $(map._container).css
          height: "#{$scope.windowHeight}px"
          width: "100%"
        map.invalidateSize(false)

    angular.element($window).bind 'resize', ->
      $scope.initializeWindowSize()
      $scope.$apply()

    # apply window resize on initialize
    $scope.initializeWindowSize()
}]
