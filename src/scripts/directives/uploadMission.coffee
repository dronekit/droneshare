angular.module('app').directive 'uploadMission', -> return {
  restrict: 'A'
  templateUrl: '/views/directives/upload-mission.html'
  controller: 'vehicleController as controller'
  scope:
    'user': '='
  link: ($scope, element, attributes, controller) ->
    $scope.vehicleDialog = ->
      controller.modal.open
        templateUrl: '/views/user/vehicle-list-modal.html'
        controller: 'alertController as controller'
        resolve:
          record: ->
            $scope.user
          modalOptions: ->
            options =
              title: 'Upload mission to vehicle'
              description: ''
              action: ''
    return
}
