angular.module('app').directive 'missionSummary', ['$window', ($window) ->
  restrict: 'A'
  templateUrl: '/views/directives/mission-summary.html'
  scope:
    mission: '='
]
