class Config
  constructor: ($routeProvider, $locationProvider) ->
    $locationProvider.html5Mode(true)

    $routeProvider
    .when '/create',
      templateUrl: '/views/login/user-create.html'
    .when '/confirm/:id/:verification',
      templateUrl: '/views/login/email-confirm.html'
    .when '/reset/:id/:verification',
      templateUrl: '/views/login/password-reset-confirm.html'
    .when '/reset',
      templateUrl: '/views/login/password-reset.html'
    .when '/logout',
      templateUrl: '/views/login/logout.html'
    .when '/login',
      templateUrl: '/views/login/login-window.html'
    .when '/user',
      templateUrl: '/views/user/list-all.html'
    .when '/user/:id',
      controller: 'userDetailController as controller'
      templateUrl: '/views/user/detail.html'
      resolve:
        resolvedUser: ['$route', 'userService', ($route, userService) ->
          userService.getId($route.current.params.id)
        ]
    .when '/vehicle',
      templateUrl: '/views/vehicle-list.html'
    .when '/vehicle/:id',
      templateUrl: '/views/vehicle-detail.html'
      controller: 'vehicleDetailController as controller'
      resolve:
        resolvedVehicle: ['$route', 'vehicleService', ($route, vehicleService) ->
          vehicleService.getId($route.current.params.id)
        ]
    .when '/mission',
      title: 'Recent'
      templateUrl: '/views/mission/list-window.html'
      controller: 'missionController as controller'
      resolve:
        preFetchedMissions: ['$route', 'missionService', ($route, missionService) ->
          missionService.getAllMissions({order_by: "createdAt", order_dir: "desc", page_size: 12})
        ]
    .when '/mission/:id',
      controller: 'missionDetailController as controller'
      title: 'Detail'
      templateUrl: '/views/mission/detail-window.html'
    .when '/parameters/:id',
      templateUrl: '/views/mission/parameters-window.html'
    .when '/analysis/:id',
      templateUrl: '/views/mission/analysis-window.html'
    .when '/doarama/:id',
      templateUrl: '/views/mission/doarama-window.html'
    .when '/mission/:id/plot',
      title: 'Plot'
      templateUrl: '/views/mission/plot-window.html'
      controller: 'missionPlotController as controller'
      resolve:
        missionData: ['$route', 'missionService', ($route, missionService) ->
          missionService.getId($route.current.params.id).then missionService.fixMissionRecord
        ]
        plotData: ['$route', 'missionService', ($route, missionService) ->
          missionService.get_plotdata($route.current.params.id).then (response) ->
            response.data
        ]
    .when '/github/:id',
      controller: 'gitHubController'
    .when '/admin',
      templateUrl: '/views/admin-screen.html'
    .when '/about',
      controller: 'aboutController'
      templateUrl: '/views/about.html'
    .when '/',
      title: 'World'
      templateUrl: '/views/site.html'
    .otherwise
      redirectTo: '/'

angular.module('app').config ['$routeProvider', '$locationProvider', Config]
angular.module('app').config ['$logProvider', ($logProvider) -> $logProvider.debugEnabled(window.debugEnabled)]

angular.module('app').run ['$location', '$rootScope', (location, rootScope) ->
  rootScope.$on '$routeChangeSuccess', (event, current, previous) ->
    rootScope.title = if current?$$route?title? then " - " + current.$$route.title else ""
]
