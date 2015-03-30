(function() {
  var AlertController, AuthController, BaseController, DetailController, EmailConfirmController, MissionAnalysisController, MissionController, MissionDetailController, MissionParameterController, MissionPlotController, MultiRecordController, UserController, UserDetailController, VehicleController, VehicleDetailController, fixupMission,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseController = (function() {
    function BaseController(scope) {
      this.scope = scope;
      this.clear_all = __bind(this.clear_all, this);
      this.clear_success = __bind(this.clear_success, this);
      this.add_success = __bind(this.add_success, this);
      this.clear_error = __bind(this.clear_error, this);
      this.set_http_error = __bind(this.set_http_error, this);
      this.set_error = __bind(this.set_error, this);
      this.add_error = __bind(this.add_error, this);
      this.clear_error();
      this.clear_success();
    }

    BaseController.prototype.add_error = function(message) {
      return this.scope.errors.push(message);
    };

    BaseController.prototype.set_error = function(message) {
      this.clear_error();
      return this.scope.errors.push(message);
    };

    BaseController.prototype.set_http_error = function(results) {
      var msg;
      this.log.debug("got error " + results.status + " " + results.statusText);
      msg = results.status === 404 ? "Record not found" : results.statusText;
      return this.set_error(msg);
    };

    BaseController.prototype.clear_error = function() {
      return this.scope.errors = [];
    };

    BaseController.prototype.add_success = function(message) {
      return this.scope.successes.push(message);
    };

    BaseController.prototype.clear_success = function(message) {
      return this.scope.successes = [];
    };

    BaseController.prototype.clear_all = function() {
      this.clear_error();
      return this.clear_success();
    };

    return BaseController;

  })();

  EmailConfirmController = (function(_super) {
    __extends(EmailConfirmController, _super);

    EmailConfirmController.$inject = ['$route', '$routeParams', '$log', '$scope', '$location', 'authService'];

    function EmailConfirmController(route, routeParams, log, scope, location, service) {
      this.route = route;
      this.routeParams = routeParams;
      this.log = log;
      this.location = location;
      this.service = service;
      this.do_email_confirm = __bind(this.do_email_confirm, this);
      EmailConfirmController.__super__.constructor.call(this, scope);
      this.do_email_confirm();
    }

    EmailConfirmController.prototype.do_email_confirm = function() {
      return this.service.email_confirm(this.routeParams.id, this.routeParams.verification).then((function(_this) {
        return function(results) {
          return _this.add_success('Your email address is now confirmed');
        };
      })(this), (function(_this) {
        return function(reason) {
          _this.log.debug("Email confirm failed due to " + reason.statusText);
          return _this.set_http_error(reason);
        };
      })(this));
    };

    return EmailConfirmController;

  })(BaseController);

  AuthController = (function(_super) {
    __extends(AuthController, _super);

    AuthController.$inject = ['$route', '$routeParams', '$log', '$scope', '$location', 'authService'];

    function AuthController(route, routeParams, log, scope, location, service) {
      this.route = route;
      this.routeParams = routeParams;
      this.log = log;
      this.location = location;
      this.service = service;
      this.isAnonymous = __bind(this.isAnonymous, this);
      this.isLoggedIn = __bind(this.isLoggedIn, this);
      AuthController.__super__.constructor.call(this, scope);
      this.login = "";
      this.password = "";
      this.email = "";
      this.fullName = "";
      this.wantEmails = true;
      this.user = null;
      this.getUser = this.service.getUser;
      this.can_login = (function(_this) {
        return function() {
          return _this.password.trim() !== "" && _this.login.trim() !== "";
        };
      })(this);
      this.can_create = (function(_this) {
        return function() {
          var _ref;
          return _this.password.trim() !== "" && _this.login.trim() !== "" && ((_ref = _this.email) != null ? _ref : "").trim() !== "" && _this.fullName.trim() !== "";
        };
      })(this);
      this.get_create_warning = (function(_this) {
        return function() {
          if (_this.email == null) {
            return "Invalid email address";
          } else if (_this.password !== "") {
            if (_this.password.length < 8) {
              return "Password too short";
            } else if (!/\d/.test(_this.password)) {
              return "Password must contain a digit";
            }
          } else {
            return null;
          }
        };
      })(this);
      this.do_login = (function(_this) {
        return function() {
          return _this.service.login(_this.login, _this.password).then(function(results) {
            return _this.location.path("/");
          }, function(reason) {
            _this.log.debug("Login failed due to " + reason.statusText);
            return _this.set_http_error(reason);
          });
        };
      })(this);
      this.do_password_reset = (function(_this) {
        return function() {
          return _this.service.password_reset(_this.login).then(function(results) {
            return _this.add_success('Password reset email sent...');
          }, function(reason) {
            _this.log.debug("Password reset failed due to " + reason.statusText);
            return _this.set_http_error(reason);
          });
        };
      })(this);
      this.do_password_reset_confirm = (function(_this) {
        return function() {
          return _this.service.password_reset_confirm(_this.routeParams.id, _this.routeParams.verification, _this.password).then(function(results) {
            _this.add_success('Your password has been reset');
            return _this.location.path("/");
          }, function(reason) {
            _this.log.debug("Password reset failed due to " + reason.statusText);
            return _this.set_http_error(reason);
          });
        };
      })(this);
      this.doCreate = (function(_this) {
        return function() {
          var payload;
          payload = {
            login: _this.login,
            password: _this.password,
            email: _this.email,
            fullName: _this.fullName,
            wantEmails: _this.wantEmails
          };
          return _this.service.create(payload).then(function(results) {
            return _this.location.path("/");
          }, function(reason) {
            _this.log.debug("Not created due to " + reason.statusText);
            return _this.set_http_error(reason);
          });
        };
      })(this);
      this.do_logout = (function(_this) {
        return function() {
          return _this.service.logout().then(function(results) {
            return _this.location.path("/");
          });
        };
      })(this);
    }

    AuthController.prototype.isLoggedIn = function() {
      return this.getUser().loggedIn;
    };

    AuthController.prototype.isAnonymous = function() {
      return !this.isLoggedIn();
    };

    AuthController.prototype.getError = function() {
      return this.service.getError();
    };

    return AuthController;

  })(BaseController);

  MultiRecordController = (function(_super) {
    __extends(MultiRecordController, _super);

    MultiRecordController.$inject = ['$log', '$scope'];

    function MultiRecordController(log, scope) {
      this.log = log;
      this.scope = scope;
      this.addRecord = __bind(this.addRecord, this);
      this.extendRecords = __bind(this.extendRecords, this);
      this.fetchAppendRecords = __bind(this.fetchAppendRecords, this);
      this.fetchRecords = __bind(this.fetchRecords, this);
      MultiRecordController.__super__.constructor.call(this, scope);
    }

    MultiRecordController.prototype.fetchRecords = function() {
      var _ref;
      return this.service.get((_ref = this.fetchParams) != null ? _ref : {}).then((function(_this) {
        return function(results) {
          _this.records = _this.extendRecords(results);
          return _this.log.debug("Fetched " + _this.records.length + " records");
        };
      })(this));
    };

    MultiRecordController.prototype.fetchAppendRecords = function() {
      var _ref;
      return this.service.get((_ref = this.fetchParams) != null ? _ref : {}).then((function(_this) {
        return function(results) {
          return _this.records = _this.records.concat(_this.extendRecords(results));
        };
      })(this));
    };

    MultiRecordController.prototype.extendRecord = function(rec) {
      return rec;
    };

    MultiRecordController.prototype.extendRecords = function(records) {
      var record, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = records.length; _i < _len; _i++) {
        record = records[_i];
        _results.push(this.extendRecord(record));
      }
      return _results;
    };

    MultiRecordController.prototype.addRecord = function(mission) {
      return this.service.save(mission).success((function(_this) {
        return function(results) {
          _this.error = '';
          _this.mission = {};
          return fetchRecords();
        };
      })(this)).error((function(_this) {
        return function(results, status) {
          if (status === 403) {
            return _this.error = results;
          }
        };
      })(this)).then(function(results) {
        return results;
      });
    };

    return MultiRecordController;

  })(BaseController);

  fixupMission = function(rec, user) {
    var date, isMine, _ref;
    date = new Date(rec.createdOn);
    rec.dateString = date.toDateString() + " - " + date.toLocaleTimeString();
    rec.text = (_ref = rec.summaryText) != null ? _ref : "Mission " + rec.id;
    isMine = user.loggedIn && (rec.userName === user.login);
    rec.staticZoom = isMine ? 10 : 8;
    return rec;
  };

  MissionController = (function(_super) {
    __extends(MissionController, _super);

    MissionController.$inject = ['$log', '$scope', 'preFetchedMissions', 'missionService', 'authService'];

    function MissionController(log, $scope, records, service, authService) {
      this.records = records;
      this.service = service;
      this.authService = authService;
      $scope.busy = false;
      MissionController.__super__.constructor.call(this, log, $scope);
    }

    return MissionController;

  })(MultiRecordController);

  UserController = (function(_super) {
    __extends(UserController, _super);

    UserController.$inject = ['$log', '$scope', 'userService'];

    function UserController(log, scope, service) {
      this.service = service;
      this.fetchRecords();
    }

    return UserController;

  })(MultiRecordController);

  VehicleController = (function(_super) {
    __extends(VehicleController, _super);

    VehicleController.$inject = ['$log', '$scope', 'vehicleService', 'authService', '$modal'];

    function VehicleController(log, scope, service, authService, modal) {
      this.scope = scope;
      this.service = service;
      this.authService = authService;
      this.modal = modal;
      this.add_vehicle = __bind(this.add_vehicle, this);
      this.remove_vehicle = __bind(this.remove_vehicle, this);
      this.remove_vehicle_modal = __bind(this.remove_vehicle_modal, this);
      this.name = "";
      this.scope.alertDialog = this.isMe = function(record) {
        var me;
        if (record == null) {
          record = false;
        }
        me = this.authService.getUser();
        return me.loggedIn && ((record != null ? record.userId : void 0) === me.id);
      };
      this.isMeOrAdmin = function(record) {
        var _ref;
        return this.isMe(record) || ((_ref = this.authService.getUser()) != null ? _ref.isAdmin : void 0);
      };
      VehicleController.__super__.constructor.call(this, log, scope);
    }

    VehicleController.prototype.remove_vehicle_modal = function(vehicle) {
      var dialog;
      dialog = this.modal.open({
        templateUrl: '/views/directives/alert-modal.html',
        controller: 'alertController as controller',
        resolve: {
          record: function() {
            return vehicle;
          },
          modalOptions: function() {
            return this.options = {
              title: "Remove Vehicle",
              description: "Are you sure you want to remove this vehicle?",
              action: "Remove"
            };
          }
        }
      });
      return dialog.result.then((function(_this) {
        return function(record) {
          return _this.remove_vehicle(record.id);
        };
      })(this));
    };

    VehicleController.prototype.remove_vehicle = function(id) {
      this.service["delete"](id).then((function(_this) {
        return function(result) {
          return _this.scope.$emit('vehicleRemoved', result);
        };
      })(this));
      return true;
    };

    VehicleController.prototype.add_vehicle = function(vehicleAppendForm) {
      var vehicle;
      if (vehicleAppendForm == null) {
        vehicleAppendForm = {
          $dirty: false
        };
      }
      vehicle = {
        name: vehicleAppendForm.$dirty ? this.name : "New vehicle"
      };
      return this.service.append(vehicle).then((function(_this) {
        return function(results) {
          return _this.scope.$emit('vehicleAdded');
        };
      })(this));
    };

    return VehicleController;

  })(MultiRecordController);

  AlertController = (function() {
    AlertController.$inject = ['$scope', '$modalInstance', 'record', 'modalOptions', '$location'];

    function AlertController($scope, $modalInstance, record, modalOptions, $location) {
      $scope.modalTitle = modalOptions.title;
      $scope.modalDescription = modalOptions.description;
      $scope.modalAction = modalOptions.action;
      $scope.record = record;
      $scope.go = (function(_this) {
        return function(path) {
          $modalInstance.close();
          return $location.path(path);
        };
      })(this);
      $scope.ok = (function(_this) {
        return function() {
          return $modalInstance.close(record);
        };
      })(this);
    }

    return AlertController;

  })();

  angular.module('app').controller('alertController', AlertController);

  angular.module('app').controller('missionController', MissionController);

  angular.module('app').controller('vehicleController', VehicleController);

  angular.module('app').controller('userController', UserController);

  angular.module('app').controller('authController', AuthController);

  angular.module('app').controller('emailConfirmController', EmailConfirmController);

  DetailController = (function(_super) {
    __extends(DetailController, _super);

    function DetailController(scope, routeParams, window, prefetch) {
      this.routeParams = routeParams;
      this.window = window;
      this.prefetch = prefetch != null ? prefetch : true;
      this.handle_fetch_response = __bind(this.handle_fetch_response, this);
      this.handle_submit_response = __bind(this.handle_submit_response, this);
      this.handle_delete_response = __bind(this.handle_delete_response, this);
      this.get_record_for_submit = __bind(this.get_record_for_submit, this);
      DetailController.__super__.constructor.call(this, scope);
      this.urlBase = this.service.urlId(this.routeParams.id);
      this["delete"] = (function(_this) {
        return function() {
          _this.clear_all();
          return _this.service["delete"](_this.routeParams.id).then(function(results) {
            return _this.handle_delete_response();
          }, function(results) {
            return _this.set_http_error(results);
          });
        };
      })(this);
      this.fetch_record = (function(_this) {
        return function() {
          _this.clear_all();
          return _this.service.getId(_this.routeParams.id).then(function(results) {
            return _this.handle_fetch_response(results);
          }, function(results) {
            return _this.set_http_error(results);
          });
        };
      })(this);
      this.submit = (function(_this) {
        return function() {
          _this.clear_all();
          return _this.service.putId(_this.routeParams.id, _this.get_record_for_submit()).then(function(results) {
            _this.add_success('Updated');
            return _this.handle_submit_response(results.data);
          }, function(results) {
            return _this.set_http_error(results);
          });
        };
      })(this);
      if (this.prefetch) {
        this.fetch_record();
      }
    }

    DetailController.prototype.get_record_for_submit = function() {
      return this.record;
    };

    DetailController.prototype.handle_delete_response = function() {
      return this.window.history.back();
    };

    DetailController.prototype.handle_submit_response = function(data) {
      return this.assign_record(data);
    };

    DetailController.prototype.handle_fetch_response = function(data) {
      return this.assign_record(data);
    };

    DetailController.prototype.assign_record = function(data) {
      this.scope.record = data;
      this.record = data;
      return this.original_record = angular.copy(this.record);
    };

    DetailController.prototype.reset_record = function() {
      return this.record = angular.copy(this.original_record);
    };

    return DetailController;

  })(BaseController);

  UserDetailController = (function(_super) {
    __extends(UserDetailController, _super);

    UserDetailController.$inject = ['$log', '$scope', '$routeParams', 'resolvedUser', 'userService', 'authService', 'vehicleService', '$window', '$modal', 'ngProgressLite', '$location'];

    function UserDetailController(log, $scope, routeParams, resolvedUser, service, authService, vehicleService, window, $modal, ngProgressLite, $location) {
      this.log = log;
      this.service = service;
      this.authService = authService;
      this.vehicleService = vehicleService;
      this.$location = $location;
      $scope.$on('loading-started', function(event, config) {
        if (event.currentScope.urlBase === config.url) {
          return ngProgressLite.start();
        }
      });
      $scope.$on('loading-complete', function(event, config) {
        if (event.currentScope.urlBase === config.url) {
          return ngProgressLite.done();
        }
      });
      UserDetailController.__super__.constructor.call(this, $scope, routeParams, window, false);
      $scope.$on('vehicleRemoved', (function(_this) {
        return function(event, response) {
          return _this.fetch_record();
        };
      })(this));
      $scope.$on('vehicleAdded', (function(_this) {
        return function(event, response) {
          $scope.controller.record.vehicles.push(response.data);
          return $scope.controller.vehicleModal.close('success');
        };
      })(this));
      this.assign_record(resolvedUser);
      this.addVehicleModal = false;
      this.isMe = (function(_this) {
        return function() {
          var _ref;
          return _this.authService.getUser().loggedIn && (((_ref = _this.record) != null ? _ref.login : void 0) === _this.authService.getUser().login);
        };
      })(this);
      this.isMeOrAdmin = (function(_this) {
        return function() {
          if (_this.isMe() || _this.authService.getUser().isAdmin) {
            return true;
          } else {
            return false;
          }
        };
      })(this);
      this.ownershipPrefix = this.isMe() ? 'My' : "" + this.record.login + "'s";
      this.showEditForm = function() {
        $('#user-details-form').toggleClass('hidden');
        return true;
      };
      this.closeEditForm = (function(_this) {
        return function() {
          _this.reset_record();
          return _this.showEditForm();
        };
      })(this);
      this.addVehicle = (function(_this) {
        return function() {
          return _this.vehicleModal = $modal.open({
            templateUrl: '/views/user/vehicle-modal.html',
            controller: 'vehicleController as controller',
            scope: $scope
          });
        };
      })(this);
    }

    return UserDetailController;

  })(DetailController);

  VehicleDetailController = (function(_super) {
    __extends(VehicleDetailController, _super);

    VehicleDetailController.$inject = ['$upload', '$log', '$scope', '$routeParams', 'resolvedVehicle', 'vehicleService', 'authService', '$window', 'ngProgressLite'];

    function VehicleDetailController(upload, log, scope, routeParams, resolvedVehicle, service, authService, window, ngProgressLite) {
      this.upload = upload;
      this.log = log;
      this.service = service;
      this.authService = authService;
      scope.$on('loading-started', function(event, config) {
        if (event.currentScope.urlBase === config.url) {
          return ngProgressLite.start();
        }
      });
      scope.$on('loading-complete', function(event, config) {
        if (event.currentScope.urlBase === config.url) {
          return ngProgressLite.done();
        }
      });
      scope.urlBase = service.urlId(routeParams.id);
      VehicleDetailController.__super__.constructor.call(this, scope, routeParams, window, false);
      this.assign_record(resolvedVehicle);
      this.uploading = false;
      this.upload_progress = 0;
      this.on_file_select = (function(_this) {
        return function(files) {
          var c;
          _this.clear_error();
          c = {
            url: _this.service.urlId(_this.routeParams.id) + '/missions',
            method: 'POST',
            file: files
          };
          angular.extend(c, _this.service.config);
          _this.uploading = true;
          return _this.upload.upload(c).progress(function(evt) {
            var progress;
            if (evt.total > 0 && _this.uploading) {
              progress = evt.loaded * 0.75;
              _this.upload_progress = parseInt(100.0 * progress / evt.total);
              return _this.log.debug('percent: ' + parseInt(100.0 * evt.loaded / evt.total));
            }
          }).success(function(data, status, headers, config) {
            _this.log.info('success!');
            _this.add_success('Upload completed!');
            _this.uploading = false;
            return _this.fetch_record();
          }).error(function(data, status, headers) {
            _this.uploading = false;
            return _this.add_error(data.message);
          });
        };
      })(this);
      this.isMine = (function(_this) {
        return function() {
          var me, _ref;
          me = _this.authService.getUser();
          return me.loggedIn && (((_ref = _this.record) != null ? _ref.userId : void 0) === me.id);
        };
      })(this);
    }

    VehicleDetailController.prototype.handle_fetch_response = function(data) {
      var rec, _i, _len, _ref;
      _ref = data.missions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        rec = _ref[_i];
        fixupMission(rec, this.authService.getUser());
      }
      return VehicleDetailController.__super__.handle_fetch_response.call(this, data);
    };

    return VehicleDetailController;

  })(DetailController);

  MissionDetailController = (function(_super) {
    __extends(MissionDetailController, _super);

    MissionDetailController.$inject = ['$modal', '$log', '$scope', '$routeParams', 'missionService', '$rootScope', 'authService', '$window', '$sce', 'ngProgressLite'];

    function MissionDetailController(modal, log, scope, routeParams, service, rootScope, authService, window, sce, ngProgressLite) {
      this.modal = modal;
      this.log = log;
      this.service = service;
      this.rootScope = rootScope;
      this.authService = authService;
      this.sce = sce;
      this.handle_fetch_response = __bind(this.handle_fetch_response, this);
      this.get_record_for_submit = __bind(this.get_record_for_submit, this);
      scope.$on('loading-started', function(event, config) {
        if (event.currentScope.urlBase === config.url) {
          return ngProgressLite.start();
        }
      });
      scope.$on('loading-complete', function(event, config) {
        if (event.currentScope.urlBase === config.url) {
          return ngProgressLite.done();
        }
      });
      MissionDetailController.__super__.constructor.call(this, scope, routeParams, window);
      this.scope.urlBase = this.urlBase;
      this.scope.center = {};
      this.scope.bounds = {};
      this.scope.geojson = {};
      this.service.get_geojson(this.routeParams.id).then((function(_this) {
        return function(result) {
          _this.log.debug("Setting geojson");
          _this.geojson = result.data;
          _this.scope.geojson = {
            data: _this.geojson,
            style: {
              fillColor: "green",
              weight: 2,
              color: 'black',
              dashArray: '3',
              fillOpacity: 0.7
            }
          };
          return _this.scope.bounds = {
            southWest: {
              lng: _this.geojson.bbox[0],
              lat: _this.geojson.bbox[1]
            },
            northEast: {
              lng: _this.geojson.bbox[3],
              lat: _this.geojson.bbox[4]
            }
          };
        };
      })(this));
      this.isMine = (function(_this) {
        return function() {
          var me, _ref;
          me = _this.authService.getUser();
          return me.loggedIn && (((_ref = _this.record) != null ? _ref.userName : void 0) === me.login);
        };
      })(this);
      this.show_parameters = (function(_this) {
        return function() {
          var dialog;
          _this.log.info('opening parameters');
          return dialog = _this.modal.open({
            templateUrl: '/views/mission/parameters-modal.html',
            controller: 'missionParameterController as controller',
            windowClass: 'parameters-modal fade'
          });
        };
      })(this);
      this.show_analysis = (function(_this) {
        return function() {
          var dialog;
          _this.log.info('opening analysis');
          return dialog = _this.modal.open({
            templateUrl: '/views/mission/analysis-modal.html',
            controller: 'missionAnalysisController as controller'
          });
        };
      })(this);
      this.show_doarama = (function(_this) {
        return function() {
          var name, x, xOffset, y, yOffset;
          _this.log.info('opening doarama');
          xOffset = 300;
          yOffset = 300;
          x = (_this.window.screenX || _this.window.screenLeft || 0) + (xOffset || 0);
          y = (_this.window.screenY || _this.window.screenTop || 0) + (yOffset || 0);
          name = 'doarama' + _this.record.id;
          return _this.window.open(_this.scope.doaramaURL, name, "width=940,height=420,scrollbars=no,left=" + x + ",top=" + y);
        };
      })(this);
    }

    MissionDetailController.prototype.get_record_for_submit = function() {
      delete this.record.viewPrivacy;
      delete this.record.createdOn;
      delete this.record.updatedOn;
      return this.record;
    };

    MissionDetailController.prototype.handle_submit_response = function(data) {};

    MissionDetailController.prototype.handle_fetch_response = function(data) {
      var avatar, url;
      MissionDetailController.__super__.handle_fetch_response.call(this, data);
      fixupMission(data, this.authService.getUser());
      if (data.latitude == null) {
        this.set_error('This mission did not include location data');
      }
      this.log.info('Setting root scope');
      this.rootScope.ogImage = data.mapThumbnailURL;
      this.rootScope.ogDescription = data.userName + " flew their drone in " + data.summaryText + " for " + Math.round(data.flightDuration / 60) + " minutes.";
      this.rootScope.ogTitle = data.userName + "'s mission";
      if (data.doaramaURL != null) {
        avatar = encodeURIComponent(data.userAvatarImage);
        url = data.doaramaURL + ("&name=" + (encodeURIComponent(data.userName)) + "&avatar=" + avatar);
        this.log.info("Doarama at " + url);
        return this.scope.doaramaURL = url;
      }
    };

    return MissionDetailController;

  })(DetailController);

  MissionParameterController = (function(_super) {
    __extends(MissionParameterController, _super);

    MissionParameterController.$inject = ['$log', '$scope', '$routeParams', 'missionService'];

    function MissionParameterController(log, scope, routeParams, service) {
      this.log = log;
      this.routeParams = routeParams;
      this.service = service;
      MissionParameterController.__super__.constructor.call(this, scope);
      this.service.get_parameters(this.routeParams.id).then((function(_this) {
        return function(httpResp) {
          var p, _i, _len, _ref, _ref1, _results;
          _this.log.debug("Setting parameters");
          _this.parameters = httpResp.data;
          _this.hasBad = false;
          _ref = _this.parameters;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            _this.hasBad = _this.hasBad || !((_ref1 = p.rangeOk) != null ? _ref1 : true);
            if (p.rangeOk != null) {
              _results.push(p.style = p.rangeOk ? "param-good" : "param-bad");
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        };
      })(this));
    }

    return MissionParameterController;

  })(BaseController);

  MissionPlotController = (function(_super) {
    __extends(MissionPlotController, _super);

    MissionPlotController.$inject = ['$log', '$scope', '$routeParams', 'missionService', 'authService', 'missionData', 'plotData'];

    function MissionPlotController(log, scope, routeParams, service, authService, record, plotData) {
      this.log = log;
      this.routeParams = routeParams;
      this.service = service;
      this.authService = authService;
      this.record = record;
      this.plotData = plotData;
      MissionPlotController.__super__.constructor.call(this, scope);
      this.isMine = (function(_this) {
        return function() {
          var me, _ref;
          me = _this.authService.getUser();
          return me.loggedIn && (((_ref = _this.record) != null ? _ref.userName : void 0) === me.login);
        };
      })(this);
      this.scope.record = this.record;
      this.scope.series = this.plotData;
    }

    return MissionPlotController;

  })(BaseController);

  MissionAnalysisController = (function(_super) {
    __extends(MissionAnalysisController, _super);

    MissionAnalysisController.$inject = ['$log', '$scope', '$routeParams', 'missionService'];

    function MissionAnalysisController(log, scope, routeParams, service) {
      this.log = log;
      this.routeParams = routeParams;
      this.service = service;
      MissionAnalysisController.__super__.constructor.call(this, scope);
      this.log.debug("Fetching analysis data for " + this.routeParams.id);
      this.service.get_analysis(this.routeParams.id).success((function(_this) {
        return function(httpResp) {
          _this.log.debug("Setting analysis");
          return _this.scope.report = httpResp;
        };
      })(this)).error((function(_this) {
        return function(httpResp, status) {
          _this.log.error("Error in analysis");
          if (status === 410) {
            return _this.scope.errorMessage = httpResp.message;
          }
        };
      })(this));
    }

    return MissionAnalysisController;

  })(BaseController);

  angular.module('app').controller('userDetailController', UserDetailController);

  angular.module('app').controller('vehicleDetailController', VehicleDetailController);

  angular.module('app').controller('missionDetailController', MissionDetailController);

  angular.module('app').controller('missionParameterController', MissionParameterController);

  angular.module('app').controller('missionPlotController', MissionPlotController);

  angular.module('app').controller('missionAnalysisController', MissionAnalysisController);

}).call(this);
