angular.module('app').config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push ['$q', '$rootScope', ($q, $rootScope) ->
    'request': (config) ->
      $rootScope.$broadcast('loading-started', config) unless /html/.test(config.url)
      return config || $q.when(config)
    'response': (response) ->
      $rootScope.$broadcast('loading-complete', response.config) unless /html/.test(response.config.url)
      return response || $q.when(response)
  ]
]
