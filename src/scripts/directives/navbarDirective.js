(function() {
  angular.module('app').directive('headerNav', [
    '$window', function($window) {
      return {
        restrict: 'A',
        transclude: true,
        templateUrl: '/views/directives/navbar.html',
        controller: 'authController',
        link: function($scope, element, attrs, authController) {
          $scope.parent_logo = $window.logos.parent;
          $scope.son_logo = $window.logos.son;
          return $scope.auth = authController;
        }
      };
    }
  ]);

}).call(this);
