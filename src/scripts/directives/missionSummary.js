(function() {
  angular.module('app').directive('missionSummary', [
    '$window', function($window) {
      return {
        restrict: 'A',
        templateUrl: '/views/directives/mission-summary.html',
        scope: {
          mission: '='
        }
      };
    }
  ]);

}).call(this);
