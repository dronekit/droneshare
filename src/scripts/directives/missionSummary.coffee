angular.module('app').directive 'missionSummary', ['$window', ($window) -> return {
  restrict: 'E'
  templateUrl: '/views/directives/mission-summary.html'
  scope:
    mission: '='
}]
