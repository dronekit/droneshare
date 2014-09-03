angular.module('app').directive 'ngLaddaBootstrap', ['$timeout', ($timeout) -> return {
  scope:
    'laddaToggle': '='
  link: ($scope, $element, $attrs) ->
    Ladda = require('./libs/ladda')
    $timeout ->
      ladda = Ladda.create($element[0])

      $scope.$watch 'laddaToggle', (newVal, oldVal) ->
        if newVal
          ladda.start() unless ladda.isLoading()

          ladda.setProgress(newVal / 100) if angular.isNumber newVal

        else if ladda.isLoading()
          ladda.stop()
}]

