(function() {
  angular.module('app').directive('userSummary', [
    '$window', function($window) {
      return {
        restrict: 'E',
        templateUrl: '/views/directives/user-summary.html',
        scope: {
          user: '='
        }
      };
    }
  ]);

}).call(this);
