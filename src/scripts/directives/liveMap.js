(function() {
  angular.module('app').directive('liveMap', [
    '$window', function($window) {
      return {
        restrict: 'A',
        transclude: true,
        controller: 'liveMapController',
        templateUrl: '/views/directives/live-map.html',
        link: function($scope, $element, attrs) {
          var sameRouteSameParams;
          sameRouteSameParams = function(config) {
            return $scope.urlBase === config.url;
          };
          $scope.$on('loading-started', function(event, config) {
            if (sameRouteSameParams(config)) {
              return $scope.recordsLoaded(false, config);
            }
          });
          $scope.$on('loading-complete', function(event, config) {
            if (sameRouteSameParams(config)) {
              return $scope.recordsLoaded(true, config);
            }
          });
          $scope.uiBounds = $('#main-navigation').height() + $('#footer').height();
          $scope.initializeWindowSize = function() {
            $scope.windowHeight = $window.innerHeight - $scope.uiBounds;
            return $scope.leafletData.getMap().then(function(map) {
              $(map._container).css({
                height: "" + $scope.windowHeight + "px",
                width: "100%"
              });
              return map.invalidateSize(false);
            });
          };
          angular.element($window).bind('resize', function() {
            $scope.initializeWindowSize();
            return $scope.$apply();
          });
          return $scope.initializeWindowSize();
        }
      };
    }
  ]);

}).call(this);
