(function() {
  var Duration;

  Duration = (function() {
    function Duration($log, $filter) {
      this.$log = $log;
      this.$filter = $filter;
      return function(seconds) {
        var hours, minutes, sec_num;
        sec_num = parseInt(seconds, 10);
        hours = Math.floor(sec_num / 3600);
        minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        seconds = sec_num - (hours * 3600) - (minutes * 60);
        if (hours < 10) {
          hours = "0" + hours;
        }
        if (minutes < 10) {
          minutes = "0" + minutes;
        }
        if (seconds < 10) {
          seconds = "0" + seconds;
        }
        return hours + ':' + minutes + ':' + seconds;
      };
    }

    return Duration;

  })();

  angular.module('app').filter('duration', ['$log', '$filter', Duration]);

}).call(this);
