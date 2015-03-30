(function() {
  angular.module('app').filter('toMapIcon', function() {
    return function(vehicleTypeStr) {
      if (vehicleTypeStr === "fixed-wing") {
        return "airport";
      } else {
        return "heliport";
      }
    };
  });

}).call(this);
