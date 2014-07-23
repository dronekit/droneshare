class AboutController
  @$inject: ['$scope', '$window']
  constructor: ($scope, $window) ->
    $scope.octocat = $window.logos.octocat

angular.module('app').controller 'aboutController', AboutController
