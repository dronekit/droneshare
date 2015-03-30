(function() {
  angular.module('app').directive('accessCodeDropdown', [
    '$window', function($window) {
      return {
        restrict: 'E',
        templateUrl: '/views/directives/access-code-dropdown.html',
        scope: {
          code: '=',
          fieldName: '=field'
        }
      };
    }
  ]);

}).call(this);
