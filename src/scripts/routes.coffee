class Config
  constructor: ($routeProvider, $locationProvider) ->
    # No workie - FIXME $locationProvider.html5Mode(true)

    $routeProvider
    .when '/create',
      templateUrl: 'views/login/user-create.html'
    .when '/confirm/:id/:verification',
      templateUrl: 'views/login/email-confirm.html'
    .when '/reset/:id/:verification',
      templateUrl: 'views/login/password-reset.html'
    .when '/logout',
      templateUrl: 'views/login/logout.html'
    .when '/login',
      templateUrl: 'views/login/login-window.html'
    .when '/user',
      templateUrl: 'views/user/list-all.html'
    .when '/user/:id',
      templateUrl: 'views/user/detail.html'
    .when '/vehicle',
      templateUrl: 'views/vehicle-list.html'
    .when '/vehicle/:id',
      templateUrl: 'views/vehicle-detail.html'
    .when '/mission',
      templateUrl: 'views/mission/list-window.html'
    .when '/mission/:id',
      controller: 'missionDetailController as controller'
      templateUrl: 'views/mission/detail-window.html'
    .when '/parameters/:id',
      templateUrl: 'views/mission/parameters-window.html'
    .when '/plot/:id',
      templateUrl: 'views/mission/plot-window.html'
      #controller: 'missionDetailController'
    .when '/github/:id',
      controller: 'gitHubController'
    .when '/admin',
      templateUrl: 'views/admin-screen.html'
    .when '/',
      templateUrl: 'views/site.html'
    .otherwise
      redirectTo: '/'

angular.module('app').config ['$routeProvider', '$locationProvider', Config]

# Raven bug tracking - FIXME - move elsewhere
#Raven.config('https://ffe3750cae4b47189ab3395c803ab8c4@app.getsentry.com/23130', {
#    # Raven settings - FIXME pull from here
#    # https://github.com/gdi2290/angular-raven
#  }).install()

# Raven.captureMessage('hello world')
#     .setUser({"id": "SERVER_RENDERED_ID", "email": "SERVER_RENDERED_EMAIL" })
