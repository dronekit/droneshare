angular.module('app').directive 'userSummary', ['$window', ($window) ->
  restrict: 'E'
  templateUrl: '/views/directives/user-summary.html'
  scope:
    user: '='
]
