(function() {
  var AdminService, AuthService, DapiService, MissionService, RESTService, UserService, VehicleService, apiKey, atmosphereOptions, merge, module,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  apiKey = "eb34bd67.megadroneshare";

  merge = function(obj1, obj2) {
    var k, newv, result, v;
    result = {};
    for (k in obj1) {
      v = obj1[k];
      newv = (k in obj2) && (typeof v === "object") ? merge(v, obj2[k]) : v;
      result[k] = newv;
    }
    for (k in obj2) {
      v = obj2[k];
      if (!(k in result)) {
        result[k] = v;
      }
    }
    return result;
  };

  atmosphereOptions = {
    contentType: 'application/json',
    transport: 'websocket',
    connectTimeout: 10000,
    reconnectInterval: 30000,
    enableXDR: true,
    timeout: 60000,
    pollingInterval: 5000,
    fallbackTransport: 'long-polling',
    headers: {
      api_key: apiKey
    }
  };

  DapiService = (function() {
    DapiService.$inject = ['$log', '$http', '$routeParams'];

    function DapiService(log, http, routeParams) {
      var base, path, useLocalServer, _ref;
      this.log = log;
      this.http = http;
      this.getError = __bind(this.getError, this);
      useLocalServer = (_ref = routeParams.local) != null ? _ref : false;
      base = useLocalServer ? 'http://localhost:8080' : 'https://api.droneshare.com';
      path = '/api/v1/';
      this.apiBase = base + path;
      this.log.debug("Creating service " + this.urlBase());
      this.error = null;
      this.config = {
        withCredentials: true,
        useXDomain: true,
        headers: {
          Authorization: 'DroneApi apikey="' + apiKey + '"'
        }
      };
    }

    DapiService.prototype.urlBase = function() {
      return this.apiBase + this.endpoint;
    };

    DapiService.prototype.getError = function() {
      return this.error;
    };

    return DapiService;

  })();

  RESTService = (function(_super) {
    __extends(RESTService, _super);

    function RESTService() {
      this.append = __bind(this.append, this);
      this["delete"] = __bind(this["delete"], this);
      this.postId = __bind(this.postId, this);
      this.putId = __bind(this.putId, this);
      return RESTService.__super__.constructor.apply(this, arguments);
    }

    RESTService.prototype.get = function(params) {
      var cfg;
      if (params == null) {
        params = {};
      }
      this.log.debug("Getting from " + this.endpoint);
      cfg = {
        params: params
      };
      angular.extend(cfg, this.config);
      return this.http.get(this.urlBase(), cfg).then(function(results) {
        return results.data;
      });
    };

    RESTService.prototype.urlId = function(id) {
      return "" + (this.urlBase()) + "/" + id;
    };

    RESTService.prototype.getId = function(id) {
      var c;
      this.log.debug("Getting " + this.endpoint + "/" + id);
      c = angular.extend({}, this.config);
      return this.http.get(this.urlId(id), c).then(function(results) {
        return results.data;
      });
    };

    RESTService.prototype.putId = function(id, obj, c) {
      this.log.debug("Saving " + this.endpoint + "/" + id);
      c = angular.extend(c != null ? c : {}, this.config);
      return this.http.put("" + (this.urlBase()) + "/" + id, obj, c);
    };

    RESTService.prototype.postId = function(id, obj, c) {
      this.log.debug("Posting to " + this.endpoint + "/" + id);
      c = merge(c != null ? c : {}, this.config);
      return this.http.post("" + (this.urlBase()) + "/" + id, obj, c);
    };

    RESTService.prototype["delete"] = function(id, c) {
      this.log.debug("Deleting " + this.endpoint + "/" + id);
      c = angular.extend(c != null ? c : {}, this.config);
      return this.http["delete"]("" + (this.urlBase()) + "/" + id, c);
    };

    RESTService.prototype.append = function(obj, c) {
      this.log.debug("Appending to " + this.endpoint);
      c = angular.extend(c != null ? c : {}, this.config);
      return this.http.put("" + (this.urlBase()), obj, c);
    };

    return RESTService;

  })(DapiService);

  AuthService = (function(_super) {
    __extends(AuthService, _super);

    AuthService.$inject = ['$log', '$http', '$routeParams'];

    function AuthService(log, http, routeParams) {
      this.getUser = __bind(this.getUser, this);
      this.setLoggedOut = __bind(this.setLoggedOut, this);
      this.setLoggedIn = __bind(this.setLoggedIn, this);
      AuthService.__super__.constructor.call(this, log, http, routeParams);
      this.setLoggedOut();
      this.checkLogin();
    }

    AuthService.prototype.endpoint = "auth";

    AuthService.prototype.logout = function() {
      this.setLoggedOut();
      return this.postId("logout");
    };

    AuthService.prototype.create = function(payload) {
      this.log.debug("Attempting create for " + payload);
      return this.postId("create", payload).success((function(_this) {
        return function(results) {
          _this.log.debug("Created in!");
          return _this.setLoggedIn(results);
        };
      })(this));
    };

    AuthService.prototype.login = function(loginName, password) {
      var config, data;
      config = {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      };
      this.log.debug("Attempting login for " + loginName);
      data = $.param({
        login: loginName,
        password: password
      });
      return this.postId("login", data, config).success((function(_this) {
        return function(results) {
          _this.log.debug("Logged in!");
          return _this.setLoggedIn(results);
        };
      })(this)).error((function(_this) {
        return function(results, status) {
          _this.log.debug("Not logged in " + results + ", " + status);
          return _this.setLoggedOut();
        };
      })(this));
    };

    AuthService.prototype.password_reset = function(loginName) {
      this.log.debug("Attempting password reset for " + loginName);
      return this.postId("pwreset/" + loginName, {});
    };

    AuthService.prototype.password_reset_confirm = function(loginName, token, newPassword) {
      this.log.debug("Attempting password confirm for " + loginName);
      return this.postId("pwreset/" + loginName + "/" + token, JSON.stringify(newPassword)).success((function(_this) {
        return function(results) {
          _this.log.debug("Password reset complete!");
          return _this.setLoggedIn(results);
        };
      })(this));
    };

    AuthService.prototype.email_confirm = function(loginName, token) {
      this.log.debug("Attempting email confirm for " + loginName);
      return this.postId("emailconfirm/" + loginName + "/" + token, {});
    };

    AuthService.prototype.setLoggedIn = function(userRecord) {
      this.user = userRecord;
      this.user.loggedIn = true;
      return this.user;
    };

    AuthService.prototype.setLoggedOut = function() {
      return this.user = {
        loggedIn: false
      };
    };

    AuthService.prototype.getUser = function() {
      return this.user;
    };

    AuthService.prototype.checkLogin = function() {
      return this.getId("user").then((function(_this) {
        return function(results) {
          _this.log.debug("login complete!");
          _this.error = null;
          return _this.setLoggedIn(results);
        };
      })(this), (function(_this) {
        return function(results) {
          _this.log.error("Login check failed " + results.status + ": " + results.statusText);
          if (results.status === 0) {
            _this.error = "DroneAPI server is offline, please try again later.";
          }
          return _this.setLoggedOut();
        };
      })(this));
    };

    return AuthService;

  })(RESTService);

  UserService = (function(_super) {
    __extends(UserService, _super);

    function UserService() {
      return UserService.__super__.constructor.apply(this, arguments);
    }

    UserService.prototype.endpoint = "user";

    return UserService;

  })(RESTService);

  VehicleService = (function(_super) {
    __extends(VehicleService, _super);

    function VehicleService() {
      return VehicleService.__super__.constructor.apply(this, arguments);
    }

    VehicleService.prototype.endpoint = "vehicle";

    VehicleService.prototype.vehicleTypes = ["quadcopter", "tricopter", "coaxial", "hexarotor", "octorotor", "fixed-wing", "ground-rover", "submarine", "airship", "flapping-wing", "boat", "free-balloon", "antenna-tracker", "generic", "rocket", "helicopter"];

    return VehicleService;

  })(RESTService);

  MissionService = (function(_super) {
    __extends(MissionService, _super);

    MissionService.$inject = ['$log', '$http', '$routeParams', 'atmosphere', 'authService'];

    function MissionService(log, http, routeParams, atmosphere, authService) {
      this.atmosphere = atmosphere;
      this.authService = authService;
      this.get_geojson = __bind(this.get_geojson, this);
      this.get_analysis = __bind(this.get_analysis, this);
      this.get_plotdata = __bind(this.get_plotdata, this);
      this.get_parameters = __bind(this.get_parameters, this);
      this.get_staticmap = __bind(this.get_staticmap, this);
      this.atmosphere_disconnect = __bind(this.atmosphere_disconnect, this);
      this.atmosphere_connect = __bind(this.atmosphere_connect, this);
      this.fixMissionRecord = __bind(this.fixMissionRecord, this);
      this.fixMissionRecords = __bind(this.fixMissionRecords, this);
      this.getMissions = __bind(this.getMissions, this);
      this.getMissionsFromParams = __bind(this.getMissionsFromParams, this);
      this.getLongitudeMissions = __bind(this.getLongitudeMissions, this);
      this.getLatitudeMissions = __bind(this.getLatitudeMissions, this);
      this.getMaxAirSpeedMissions = __bind(this.getMaxAirSpeedMissions, this);
      this.getMaxGroundSpeedMissions = __bind(this.getMaxGroundSpeedMissions, this);
      this.getMaxAltMissions = __bind(this.getMaxAltMissions, this);
      this.getDurationMissions = __bind(this.getDurationMissions, this);
      this.getVehicleTypeMissions = __bind(this.getVehicleTypeMissions, this);
      this.getUserMissions = __bind(this.getUserMissions, this);
      this.getAllMissions = __bind(this.getAllMissions, this);
      this.fetchParams = this.getFetchParams();
      this.createdAt = 'desc';
      this.userWatching = this.authService.getUser();
      MissionService.__super__.constructor.call(this, log, http, routeParams);
    }

    MissionService.prototype.endpoint = "mission";

    MissionService.prototype.getAllMissions = function(fetchParams) {
      fetchParams || (fetchParams = this.getFetchParams());
      return this.getMissionsFromParams(fetchParams);
    };

    MissionService.prototype.getUserMissions = function(userLogin, filterParams) {
      var fetchParams;
      if (filterParams == null) {
        filterParams = false;
      }
      fetchParams = {
        field_userName: userLogin
      };
      if (filterParams) {
        angular.extend(fetchParams, filterParams);
      }
      return this.getMissionsFromParams(fetchParams);
    };

    MissionService.prototype.getVehicleTypeMissions = function(vehicleType) {
      var fetchParams;
      fetchParams = {
        field_vehicleType: vehicleType
      };
      return this.getMissionsFromParams(fetchParams);
    };

    MissionService.prototype.getDurationMissions = function(duration, opt) {
      var fetchParams;
      if (opt == null) {
        opt = 'GT';
      }
      fetchParams = {};
      fetchParams["field_flightDuration[" + opt + "]"] = duration;
      return this.getMissionsFromParams(fetchParams);
    };

    MissionService.prototype.getMaxAltMissions = function(altitude, opt) {
      var fetchParams;
      if (opt == null) {
        opt = 'GT';
      }
      fetchParams = {};
      fetchParams["field_maxAlt[" + opt + "]"] = altitude;
      return this.getMissionsFromParams(fetchParams);
    };

    MissionService.prototype.getMaxGroundSpeedMissions = function(speed, opt) {
      var fetchParams;
      if (opt == null) {
        opt = 'GT';
      }
      fetchParams = {};
      fetchParams["field_maxGroundspeed[" + opt + "]"] = speed;
      return this.getMissionsFromParams(fetchParams);
    };

    MissionService.prototype.getMaxAirSpeedMissions = function(speed, opt) {
      var fetchParams;
      if (opt == null) {
        opt = 'GT';
      }
      fetchParams = {};
      fetchParams["field_maxAirspeed[" + opt + "]"] = speed;
      return this.getMissionsFromParams(fetchParams);
    };

    MissionService.prototype.getLatitudeMissions = function(latitude, opt) {
      var fetchParams;
      if (opt == null) {
        opt = 'GT';
      }
      fetchParams = {};
      fetchParams["field_latitude[" + opt + "]"] = latitude;
      return this.getMissionsFromParams(fetchParams);
    };

    MissionService.prototype.getLongitudeMissions = function(longitude, opt) {
      var fetchParams;
      if (opt == null) {
        opt = 'GT';
      }
      fetchParams = {};
      fetchParams["field_longitude[" + opt] = longitude;
      return this.getMissionsFromParams(fetchParams);
    };

    MissionService.prototype.getMissionsFromParams = function(params) {
      angular.extend(params, this.getFetchParams());
      return this.getMissions(params);
    };

    MissionService.prototype.getMissions = function(params) {
      var missions;
      missions = this.get(params);
      return missions.then(this.fixMissionRecords);
    };

    MissionService.prototype.fixMissionRecords = function(results) {
      var record, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = results.length; _i < _len; _i++) {
        record = results[_i];
        _results.push(this.fixMissionRecord(record));
      }
      return _results;
    };

    MissionService.prototype.fixMissionRecord = function(record) {
      var date, isMine, _ref;
      date = new Date(record.createdOn);
      record.dateString = "" + (date.toDateString()) + " - " + (date.toLocaleTimeString());
      record.text = (_ref = record.summaryText) != null ? _ref : "Mission " + record.id;
      isMine = this.userWatching.loggedIn && (record.userName === this.userWatching.login);
      record.staticZoom = isMine ? 10 : 8;
      return record;
    };

    MissionService.prototype.getFetchParams = function() {
      var fetchParams;
      return fetchParams = {
        order_by: 'createdAt',
        order_dir: this.createdAt,
        page_offset: 0,
        page_size: 12
      };
    };

    MissionService.prototype.atmosphere_connect = function() {
      var request;
      request = {
        url: this.urlBase() + '/live'
      };
      angular.extend(request, this.config);
      angular.extend(request, atmosphereOptions);
      if (this.authService.getUser().login != null) {
        request.headers.login = this.authService.getUser().login;
      }
      return this.atmosphere.init(request);
    };

    MissionService.prototype.atmosphere_disconnect = function() {
      return this.atmosphere.close();
    };

    MissionService.prototype.get_staticmap = function() {
      return this.getId("staticMap");
    };

    MissionService.prototype.get_parameters = function(id) {
      var c;
      c = angular.extend({}, this.config);
      return this.http.get("" + (this.urlBase()) + "/" + id + "/parameters.json", c).success(function(results) {
        return results.data;
      });
    };

    MissionService.prototype.get_plotdata = function(id) {
      var c;
      c = angular.extend({}, this.config);
      return this.http.get("" + (this.urlBase()) + "/" + id + "/dseries", c).success(function(results) {
        return results.data;
      });
    };

    MissionService.prototype.get_analysis = function(id) {
      var c;
      c = angular.extend({}, this.config);
      return this.http.get("" + (this.urlBase()) + "/" + id + "/analysis.json", c).success(function(results) {
        return results.data;
      });
    };

    MissionService.prototype.get_geojson = function(id) {
      var c;
      c = angular.extend({}, this.config);
      return this.http.get("" + (this.urlBase()) + "/" + id + "/messages.geo.json", c);
    };

    return MissionService;

  })(RESTService);

  AdminService = (function(_super) {
    __extends(AdminService, _super);

    AdminService.$inject = ['$log', '$http', '$routeParams', 'atmosphere'];

    function AdminService(log, http, routeParams, atmosphere) {
      var request;
      this.atmosphere = atmosphere;
      this.getDebugInfo = __bind(this.getDebugInfo, this);
      this.importOld = __bind(this.importOld, this);
      this.startSim = __bind(this.startSim, this);
      AdminService.__super__.constructor.call(this, log, http, routeParams);
      request = {
        url: this.urlBase() + '/log'
      };
      angular.extend(request, this.config);
      angular.extend(request, atmosphereOptions);
      this.atmosphere.init(request);
    }

    AdminService.prototype.endpoint = "admin";

    AdminService.prototype.startSim = function(typ) {
      this.log.info("Service starting sim " + typ);
      return this.postId("sim/" + typ);
    };

    AdminService.prototype.importOld = function(count) {
      this.log.info("importing " + count);
      return this.postId("import/" + count);
    };

    AdminService.prototype.getDebugInfo = function() {
      return this.getId("debugInfo");
    };

    return AdminService;

  })(RESTService);

  module = angular.module('app');

  module.service('missionService', MissionService);

  module.service('userService', UserService);

  module.service('vehicleService', VehicleService);

  module.service('authService', AuthService);

  module.service('adminService', AdminService);

}).call(this);
