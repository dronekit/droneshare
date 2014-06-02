angular.module('app').directive 'headerNav', -> return {
  restrict: 'A'
  transclude: true
  templateUrl: '/views/directives/navbar.html'
  controller: 'authController'
  link: ($scope, element, attrs, authController) ->
    $scope.auth = authController
}
