angular.module('app').directive 'accessCodeDropdown', ['$window', ($window) ->
  restrict: 'E'
  templateUrl: '/views/directives/access-code-dropdown.html'
  scope:
    code: '='
    fieldName: '=field'
]
