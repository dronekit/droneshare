angular.module('app').directive 'missionSummary', ['$window', ($window) ->
  restrict: 'E'
  templateUrl: '/views/directives/mission-summary.html'
  scope:
    mission: '='
]
