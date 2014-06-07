angular.module('app').directive 'headerNav', [ '$window', ($window) -> return {
  restrict: 'A'
  transclude: true
  templateUrl: '/views/directives/navbar.html'
  controller: 'authController'
  link: ($scope, element, attrs, authController) ->
    $scope.parent_logo = $window.logos.parent
    $scope.son_logo = $window.logos.son
    $scope.auth = authController
}]
