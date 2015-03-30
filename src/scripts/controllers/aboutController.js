(function() {
  var AboutController;

  AboutController = (function() {
    AboutController.$inject = ['$scope', '$window'];

    function AboutController($scope, $window) {
      $scope.octocat = $window.logos.octocat;
    }

    return AboutController;

  })();

  angular.module('app').controller('aboutController', AboutController);

}).call(this);
