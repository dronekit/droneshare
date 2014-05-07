angular.module('app').directive 'headerNav', -> return {
  restrict: 'A'
  transclude: true
  template: '<div id="main-navigation" class="navbar navbar-default" role="navigation" ng-transclude></div>'
  controller: 'authController'
  link: ($scope, element, attrs, authController) ->
    $scope.auth = authController
}
