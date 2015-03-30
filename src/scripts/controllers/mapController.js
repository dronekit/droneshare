(function() {
  var BoundsFactory, LiveMapController, MapController, useAtmosphere,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  useAtmosphere = false;

  MapController = (function() {
    MapController.$inject = ['$scope', '$http'];

    function MapController(scope, http) {
      this.scope = scope;
      this.http = http;
      this.initMap = __bind(this.initMap, this);
      this.initMap();
    }

    MapController.prototype.initMap = function() {
      var maps, mbox, typ;
      typ = "xyz";
      mbox = function(key, name, attribution) {
        return {
          url: "https://a.tiles.mapbox.com/v3/" + key + "/{z}/{x}/{y}.png",
          name: name,
          type: typ,
          layerOptions: {
            attribution: attribution || '<a href="http://www.mapbox.com/about/maps/" target="_blank">Terms &amp; Feedback</a>'
          }
        };
      };
      maps = {
        threedr_default: mbox("kevin3dr.hokdl9ko", "Topographic"),
        threedr_satview: mbox("kevin3dr.io0162i9", "Satellite"),
        airspace_warning: mbox("mslee.h1kk2o6r", "Restricted Zones", '<a href="http://openstreetmap.org">NPS</a>, <a href="https://explore.data.gov/National-Security-and-Veterans-Affairs/Military-Installations-Ranges-and-Training-Areas/wcc7-57p3">US Military Data</a>'),
        openstreetmap: {
          url: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          name: "OpenStreetMap",
          type: typ,
          layerOptions: {
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          }
        }
      };
      this.scope.defaults = {
        scrollWheelZoom: true,
        zoom: 10,
        minZoom: 2,
        maxZoom: 19
      };
      this.scope.tiles = maps.threedr_default;
      return this.scope.layers = {
        baselayers: maps
      };
    };

    return MapController;

  })();

  BoundsFactory = (function() {
    function BoundsFactory() {
      this.bounds = {
        northEast: {
          lat: -Number.MAX_VALUE,
          lng: -Number.MAX_VALUE
        },
        southWest: {
          lat: Number.MAX_VALUE,
          lng: Number.MAX_VALUE
        }
      };
    }

    BoundsFactory.prototype.expand = function(lat, lon) {
      var dirty, max, min, roundDown, roundUp;
      roundUp = function(x) {
        return Math.ceil(x * 10) / 10.0;
      };
      roundDown = function(x) {
        return Math.floor(x * 10) / 10.0;
      };
      dirty = false;
      min = function(newval, old) {
        if (newval < old) {
          dirty = true;
          return newval;
        } else {
          return old;
        }
      };
      max = function(newval, old) {
        if (newval > old) {
          dirty = true;
          return newval;
        } else {
          return old;
        }
      };
      this.bounds.southWest.lat = min(roundDown(lat), this.bounds.southWest.lat);
      this.bounds.southWest.lng = min(roundDown(lon), this.bounds.southWest.lng);
      this.bounds.northEast.lat = max(roundUp(lat), this.bounds.northEast.lat);
      this.bounds.northEast.lng = max(roundUp(lon), this.bounds.northEast.lng);
      return dirty;
    };

    return BoundsFactory;

  })();

  LiveMapController = (function(_super) {
    __extends(LiveMapController, _super);

    LiveMapController.$inject = ['$scope', '$log', 'leafletData', '$http', 'missionService', 'authService', '$window', 'ngProgressLite'];

    function LiveMapController(scope, log, leafletData, http, missionService, authService, window, ngProgressLite) {
      this.log = log;
      this.missionService = missionService;
      this.authService = authService;
      this.window = window;
      this.motionTracking = __bind(this.motionTracking, this);
      this.updateVehicleMessage = __bind(this.updateVehicleMessage, this);
      this.updateVehicle = __bind(this.updateVehicle, this);
      this.zoomToVehicle = __bind(this.zoomToVehicle, this);
      this.onMissionDelete = __bind(this.onMissionDelete, this);
      this.onMissionUpdateCommon = __bind(this.onMissionUpdateCommon, this);
      this.onMissionUpdate = __bind(this.onMissionUpdate, this);
      this.onAttitude = __bind(this.onAttitude, this);
      this.disconnectAtmo = __bind(this.disconnectAtmo, this);
      this.connectAtmo = __bind(this.connectAtmo, this);
      this.onLive = __bind(this.onLive, this);
      scope.leafletData = leafletData;
      this.boundsFactory = new BoundsFactory;
      this.currentMissionId = -1;
      scope.recordsLoaded = function(mode, config) {
        if (mode) {
          return ngProgressLite.done();
        } else {
          return ngProgressLite.start();
        }
      };
      scope.vehicleMarkers = {};
      scope.vehiclePaths = {};
      scope.bounds = {};
      scope.center = {};
      scope.auth = authService;
      scope.$watch('auth.user', (function(_this) {
        return function() {
          _this.log.info("Restarting atmosphere due to username change");
          _this.disconnectAtmo();
          return _this.connectAtmo();
        };
      })(this));
      LiveMapController.__super__.constructor.call(this, scope, http);
      scope.urlBase = "" + (missionService.urlBase()) + "/staticMap";
      this.connectAtmo();
      scope.$on("$destroy", (function(_this) {
        return function() {
          return _this.disconnectAtmo;
        };
      })(this));
    }

    LiveMapController.prototype.onLive = function(data) {
      return this.scope.$apply((function(_this) {
        return function() {
          var key;
          key = _this.vehicleKey(data.missionId);
          return _this.updateVehicle(key, data.payload.lat, data.payload.lon);
        };
      })(this));
    };

    LiveMapController.prototype.connectAtmo = function() {
      var callback, listeners, name, s;
      if (useAtmosphere) {
        this.log.debug('live map now subscribed');
        listeners = {
          "loc": this.onLive,
          "att": this.onAttitude,
          "stop": this.onMissionDelete,
          "mode": this.updateVehicleMessage,
          "arm": this.updateVehicleMessage,
          "update": this.onMissionUpdate,
          "start": this.onMissionUpdate,
          "user": this.onMissionUpdate,
          "delete": this.onMissionDelete,
          "mystery": this.updateVehicleMessage,
          "text": this.updateVehicleMessage
        };
        s = this.missionService;
        for (name in listeners) {
          callback = listeners[name];
          this.listenerIds = s.atmosphere.on(name, callback);
        }
        return s.atmosphere_connect();
      } else {
        this.log.debug('doing non atmo fetch');
        return this.missionService.get_staticmap().then((function(_this) {
          return function(results) {
            var update, _i, _len, _ref, _results;
            _ref = results.updates;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              update = _ref[_i];
              _results.push(_this.onMissionUpdateCommon(update));
            }
            return _results;
          };
        })(this), (function(_this) {
          return function(results) {
            return _this.set_http_error(results);
          };
        })(this));
      }
    };

    LiveMapController.prototype.disconnectAtmo = function() {
      var id, s;
      if (useAtmosphere) {
        this.log.debug('Unsubscribe for atmosphere notification');
        s = this.missionService;
        for (id in this.listenerIds) {
          s.atmosphere.off(id);
        }
        return s.atmosphere_disconnect();
      }
    };

    LiveMapController.prototype.onAttitude = function(data) {
      return this.scope.$apply((function(_this) {
        return function() {
          var key, v;
          key = _this.vehicleKey(data.missionId);
          v = _this.scope.vehicleMarkers[key];
          if (v != null) {
            return v.iconAngle = data.payload.yaw;
          }
        };
      })(this));
    };

    LiveMapController.prototype.onMissionUpdate = function(data) {
      return this.scope.$apply((function(_this) {
        return function() {
          return _this.onMissionUpdateCommon(data);
        };
      })(this));
    };

    LiveMapController.prototype.onMissionUpdateCommon = function(data) {
      var key, lat, lon, payload, v;
      key = this.vehicleKey(data.missionId);
      payload = data.payload;
      lat = payload.latitude;
      lon = payload.longitude;
      if ((lat != null) && (lon != null)) {
        v = this.updateVehicle(key, lat, lon, payload);
        this.updateMarkerPopup(v, payload);
        if (v.isMine) {
          return this.zoomToVehicle(v);
        }
      }
    };

    LiveMapController.prototype.onMissionDelete = function(data) {
      return this.scope.$apply((function(_this) {
        return function() {
          var key;
          key = _this.vehicleKey(data.missionId);
          return delete _this.scope.vehicleMarkers[key];
        };
      })(this));
    };

    LiveMapController.prototype.zoomToVehicle = function(vehicle) {
      var lat, lon, payload;
      payload = vehicle.payload;
      lat = payload.latitude;
      lon = payload.longitude;
      if (payload.id !== this.currentMissionId) {
        this.log.debug("Zooming to " + payload.id);
        this.currentMissionId = payload.id;
        return this.scope.center = {
          lat: lat,
          lng: lon,
          zoom: 9
        };
      }
    };

    LiveMapController.prototype.updateVehicle = function(vehicleKey, lat, lon, newMission) {
      var isLive, loginName, mission, v, _ref, _ref1, _ref2;
      v = (_ref = this.scope.vehicleMarkers[vehicleKey]) != null ? _ref : {};
      if (v.payload == null) {
        v.payload = {};
      }
      if (newMission != null) {
        angular.extend(v.payload, newMission);
      }
      v.lat = lat;
      v.lng = lon;
      v.focus = false;
      v.draggable = false;
      mission = v.payload;
      isLive = (_ref1 = mission != null ? mission.isLive : void 0) != null ? _ref1 : true;
      loginName = (_ref2 = this.authService.getUser()) != null ? _ref2.login : void 0;
      v.isMine = loginName === (mission != null ? mission.userName : void 0);
      this.log.debug("" + (mission != null ? mission.userName : void 0) + " " + (mission != null ? mission.id : void 0) + " vs " + loginName + " isMine=" + v.isMine);
      v.icon = {
        iconUrl: v.isMine ? mission.userAvatarImage + '?d=mm' : isLive ? this.window.logos.vehicleMarkerActive : this.window.logos.vehicleMarkerInactive,
        iconSize: [35, 35],
        iconAnchor: [17.5, 17.5],
        popupAnchor: [0, -17.5]
      };
      if (v.isMine) {
        v.icon.className = "img-rounded";
      }
      this.scope.vehicleMarkers[vehicleKey] = v;
      this.motionTracking(vehicleKey, {
        lat: lat,
        lng: lon
      });
      return v;
    };

    LiveMapController.prototype.updateVehicleMessage = function(data) {
      return this.scope.$apply((function(_this) {
        return function() {
          var marker, vehicleKey;
          vehicleKey = _this.vehicleKey(data.missionId);
          marker = _this.scope.vehicleMarkers[vehicleKey];
          return _this.updateMarkerPopup(marker, data.payload);
        };
      })(this));
    };

    LiveMapController.prototype.updateMarkerPopup = function(marker, payload) {
      var avatarImg, durationString, p;
      if (marker != null) {
        angular.extend(marker.payload, payload);
        p = marker.payload;
        if ((p.userName != null) && (p.id != null) && (p.summaryText != null)) {
          avatarImg = p.userAvatarImage != null ? "<img src=\"" + p.userAvatarImage + "?s=40&d=mm\"></img>" : "";
          durationString = p.flightDuration != null ? "" + (Math.round(p.flightDuration / 60)) + " minutes<br>" : "";
          return marker.message = "<!-- Two columns -->\n<table id=\"map-info-popup\">\n  <tr>\n    <td>\n      " + avatarImg + "\n    </td>\n\n    <td>\n      <a href='/user/" + p.userName + "'>" + p.userName + "</a><br>\n      <a href='/mission/" + p.id + "'>" + p.summaryText + "</a><br>\n      " + durationString + "\n    </td>\n  </tr>\n</table>";
        } else {
          return this.log.error("Skipping popup generation - not enough vehicle data");
        }
      }
    };

    LiveMapController.prototype.motionTracking = function(vehicleKey, latlng) {
      var v, _ref;
      v = (_ref = this.scope.vehiclePaths[vehicleKey]) != null ? _ref : {
        color: '#f76944',
        weight: 7,
        latlngs: []
      };
      v.latlngs = v.latlngs.slice(0, 100);
      v.latlngs.push(latlng);
      return this.scope.vehiclePaths[vehicleKey] = v;
    };

    LiveMapController.prototype.vehicleKey = function(vehicleId) {
      return "missionId_" + vehicleId;
    };

    return LiveMapController;

  })(MapController);

  angular.module('app').controller('mapController', MapController);

  angular.module('app').controller('liveMapController', LiveMapController);

}).call(this);
