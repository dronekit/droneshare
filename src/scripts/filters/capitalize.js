(function() {
  var Capitalize;

  Capitalize = (function() {
    function Capitalize($filter) {
      this.$filter = $filter;
      return function(words) {
        return (words.split(' ').map(function(word) {
          return word.charAt(0).toUpperCase() + word.slice(1);
        })).join('');
      };
    }

    return Capitalize;

  })();

  angular.module('app').filter('capitalize', ['$filter', Capitalize]);

}).call(this);
