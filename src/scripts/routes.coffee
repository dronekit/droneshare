class Config
  constructor: ($routeProvider) ->
    $routeProvider
    .when '/mission/:id',
      templateUrl: 'views/mission-detail.html'
      controller: 'missionDetailController'
    .when '/github/:id',
      controller: 'gitHubController'
    .when '/',
      templateUrl: 'views/site.html'
    .otherwise
      redirectTo: '/'

angular.module('app').config ['$routeProvider', Config]
