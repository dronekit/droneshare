(function() {
  var Config, Interceptor;

  Interceptor = (function() {
    function Interceptor($log, $rootScope, $q) {
      return {
        response: function(response) {
          $rootScope.$broadcast("success:" + response.status, response);
          return response;
        },
        responseError: function(response) {
          $rootScope.$broadcast("error:" + response.status, response);
          return $q.reject(response);
        }
      };
    }

    return Interceptor;

  })();

  Config = (function() {
    function Config($httpProvider) {
      $httpProvider.interceptors.push(['$log', '$rootScope', '$q', Interceptor]);
    }

    return Config;

  })();

  angular.module('app').config(['$httpProvider', Config]);

}).call(this);
