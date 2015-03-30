(function() {
  angular.module('app').directive('uploadMission', function() {
    return {
      restrict: 'A',
      templateUrl: '/views/directives/upload-mission.html',
      controller: 'vehicleController as controller',
      scope: {
        'user': '='
      },
      link: function($scope, element, attributes, controller) {
        $scope.vehicleDialog = function() {
          return controller.modal.open({
            templateUrl: '/views/user/vehicle-list-modal.html',
            controller: 'alertController as controller',
            resolve: {
              record: function() {
                return $scope.user;
              },
              modalOptions: function() {
                var options;
                return options = {
                  title: 'Upload mission to vehicle',
                  description: '',
                  action: ''
                };
              }
            }
          });
        };
      }
    };
  });

}).call(this);
