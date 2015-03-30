(function() {
  var Config;

  Config = (function() {
    function Config($routeProvider, $locationProvider) {
      $locationProvider.html5Mode(true);
      $routeProvider.when('/create', {
        templateUrl: '/views/login/user-create.html'
      }).when('/confirm/:id/:verification', {
        templateUrl: '/views/login/email-confirm.html'
      }).when('/reset/:id/:verification', {
        templateUrl: '/views/login/password-reset-confirm.html'
      }).when('/reset', {
        templateUrl: '/views/login/password-reset.html'
      }).when('/logout', {
        templateUrl: '/views/login/logout.html'
      }).when('/login', {
        templateUrl: '/views/login/login-window.html'
      }).when('/user', {
        templateUrl: '/views/user/list-all.html'
      }).when('/user/:id', {
        controller: 'userDetailController as controller',
        templateUrl: '/views/user/detail.html',
        resolve: {
          resolvedUser: [
            '$route', 'userService', function($route, userService) {
              return userService.getId($route.current.params.id);
            }
          ]
        }
      }).when('/vehicle', {
        templateUrl: '/views/vehicle-list.html'
      }).when('/vehicle/:id', {
        templateUrl: '/views/vehicle-detail.html',
        controller: 'vehicleDetailController as controller',
        resolve: {
          resolvedVehicle: [
            '$route', 'vehicleService', function($route, vehicleService) {
              return vehicleService.getId($route.current.params.id);
            }
          ]
        }
      }).when('/mission', {
        title: 'Recent',
        templateUrl: '/views/mission/list-window.html',
        controller: 'missionController as controller',
        resolve: {
          preFetchedMissions: [
            '$route', 'missionService', function($route, missionService) {
              return missionService.getAllMissions({
                order_by: "createdAt",
                order_dir: "desc",
                page_size: 12
              });
            }
          ]
        }
      }).when('/mission/:id', {
        controller: 'missionDetailController as controller',
        title: 'Detail',
        templateUrl: '/views/mission/detail-window.html'
      }).when('/parameters/:id', {
        templateUrl: '/views/mission/parameters-window.html'
      }).when('/analysis/:id', {
        templateUrl: '/views/mission/analysis-window.html'
      }).when('/doarama/:id', {
        templateUrl: '/views/mission/doarama-window.html'
      }).when('/mission/:id/plot', {
        title: 'Plot',
        templateUrl: '/views/mission/plot-window.html',
        controller: 'missionPlotController as controller',
        resolve: {
          missionData: [
            '$route', 'missionService', function($route, missionService) {
              return missionService.getId($route.current.params.id).then(missionService.fixMissionRecord);
            }
          ],
          plotData: [
            '$route', 'missionService', function($route, missionService) {
              return missionService.get_plotdata($route.current.params.id).then(function(response) {
                return response.data;
              });
            }
          ]
        }
      }).when('/github/:id', {
        controller: 'gitHubController'
      }).when('/admin', {
        templateUrl: '/views/admin-screen.html'
      }).when('/about', {
        controller: 'aboutController',
        templateUrl: '/views/about.html'
      }).when('/', {
        title: 'World',
        templateUrl: '/views/site.html'
      }).otherwise({
        redirectTo: '/'
      });
    }

    return Config;

  })();

  angular.module('app').config(['$routeProvider', '$locationProvider', Config]);

  angular.module('app').config([
    '$logProvider', function($logProvider) {
      return $logProvider.debugEnabled(window.debugEnabled);
    }
  ]);

  angular.module('app').run([
    '$location', '$rootScope', function(location, rootScope) {
      return rootScope.$on('$routeChangeSuccess', function(event, current, previous) {
        return rootScope.title = (typeof current === "function" ? current(typeof $$route === "function" ? $$route(typeof title !== "undefined" && title !== null) : void 0) : void 0) ? " - " + current.$$route.title : "";
      });
    }
  ]);

}).call(this);
