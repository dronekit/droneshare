(function() {
  angular.module('app').config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push([
        '$q', '$rootScope', function($q, $rootScope) {
          return {
            'request': function(config) {
              if (!/html/.test(config.url)) {
                $rootScope.$broadcast('loading-started', config);
              }
              return config || $q.when(config);
            },
            'response': function(response) {
              if (!/html/.test(response.config.url)) {
                $rootScope.$broadcast('loading-complete', response.config);
              }
              return response || $q.when(response);
            }
          };
        }
      ]);
    }
  ]);

}).call(this);
