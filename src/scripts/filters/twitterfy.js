(function() {
  var Filter;

  Filter = (function() {
    function Filter($log) {
      this.$log = $log;
      return function(username) {
        return "@" + username;
      };
    }

    return Filter;

  })();

  angular.module('app').filter('twitterfy', ['$log', Filter]);

}).call(this);
