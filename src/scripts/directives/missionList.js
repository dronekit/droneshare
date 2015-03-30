(function() {
  angular.module('app').directive('missionList', [
    '$log', function($log) {
      return {
        restrict: 'A',
        controllerAs: 'controller',
        templateUrl: '/views/directives/mission-list.html',
        scope: {
          'pageSize': '=',
          'noInfiniteScroll': '=',
          'preFetched': '=',
          'records': '='
        },
        controller: [
          '$scope', '$sce', 'missionService', 'authService', function(scope, sce, service, authService) {
            this.scope = scope;
            this.sce = sce;
            this.service = service;
            this.authService = authService;
            this.currentUser = this.authService.getUser();
            if (this.scope.preFetched) {
              this.scope.busy = false;
            } else {
              this.scope.busy = true;
              this.allMissions().then((function(_this) {
                return function(results) {
                  return _this.scope.busy = false;
                };
              })(this));
            }
            this.createdAt = 'desc';
            this.scope.filterInProgress = false;
            this.scope.filtersActive = false;
            this.scope.loaded = this.scope.preFetched ? true : false;
            this.scope.missionScopeTitle = 'All';
            this.scope.missionDataSet = 'all';
            this.scope.missionDataSetOptions = [
              {
                value: 'all',
                label: 'All Missions'
              }, {
                value: 'mine',
                label: 'My Missions'
              }
            ];
            this.scope.vehicleType = '';
            this.scope.dropDownIsOpen = {
              field: false,
              opt: false
            };
            this.getFetchParams = (function(_this) {
              return function() {
                var fetchParams;
                return fetchParams = {
                  order_by: 'createdAt',
                  order_dir: _this.createdAt,
                  page_offset: 0,
                  page_size: 12
                };
              };
            })(this);
            this.setFetchParamsFilter = (function(_this) {
              return function(value) {
                _this.fetchParams = _this.getFetchParams();
                _this.fetchParams["" + _this.scope.filters.field.field + "[" + _this.scope.filters.opt.opt + "]"] = value;
                return _this.fetchParams;
              };
            })(this);
            this.createFilterField = function(title, field, units) {
              var filter;
              return filter = {
                title: title,
                field: field,
                units: units
              };
            };
            this.createFilterOpt = (function(_this) {
              return function(title, opt, humanize) {
                var filter;
                return filter = {
                  title: _this.sce.trustAsHtml(title),
                  opt: opt,
                  humanize: humanize
                };
              };
            })(this);
            this.fetchParams = this.getFetchParams();
            this.filterFields = [this.createFilterField('Max Groundspeed', 'field_maxGroundspeed', 'm/s'), this.createFilterField('Duration', 'field_flightDuration', 'min'), this.createFilterField('Max Airspeed', 'field_maxAirspeed', 'm/s'), this.createFilterField('Max Altitude', 'field_maxAlt', 'm')];
            this.filterOpts = [this.createFilterOpt('Greater than', 'GT', 'greater than'), this.createFilterOpt('Greater or Equal to', 'GE', 'greater or equal to'), this.createFilterOpt('Equal to', 'EQ', 'equal to'), this.createFilterOpt('Lower than', 'LT', 'lower than'), this.createFilterOpt('Lower or Equal to', 'LE', 'equal or lower than'), this.createFilterOpt('Different than', 'NE', 'different than')];
            this.scope.filters = {
              field: this.filterFields[0],
              opt: this.filterOpts[0],
              input: '',
              dataset: ''
            };
            this.vehicleTypes = ["quadcopter", "tricopter", "coaxial", "hexarotor", "octorotor", "fixed-wing", "ground-rover", "submarine", "airship", "flapping-wing", "boat", "free-balloon", "antenna-tracker", "generic", "rocket", "helicopter"];
            this.allMissions = (function(_this) {
              return function() {
                _this.scope.missionScopeTitle = "All";
                _this.fetchParams = _this.getFetchParams();
                return _this.service.getAllMissions().then(_this.assignRecords);
              };
            })(this);
            this.userMissions = (function(_this) {
              return function(filterParams) {
                if (filterParams == null) {
                  filterParams = false;
                }
                _this.scope.missionScopeTitle = "My";
                _this.fetchParams = _this.getFetchParams();
                _this.fetchParams['field_userName'] = _this.currentUser.login;
                return _this.service.getUserMissions(_this.currentUser.login, filterParams).then(_this.assignRecords);
              };
            })(this);
            this.getVehicleTypeMissions = (function(_this) {
              return function(vehicleType) {
                return _this.service.getVehicleTypeMissions(vehicleType).then(_this.assignRecords);
              };
            })(this);
            this.getDurationMissions = (function(_this) {
              return function(duration, opt) {
                return _this.service.getDurationMissions(duration, opt).then(_this.assignRecords);
              };
            })(this);
            this.getMaxAltMissions = (function(_this) {
              return function(maxAlt, opt) {
                return _this.service.getMaxAltMissions(maxAlt, opt).then(_this.assignRecords);
              };
            })(this);
            this.getMaxGroundSpeedMissions = (function(_this) {
              return function(speed, opt) {
                return _this.service.getMaxGroundSpeedMissions(speed, opt).then(_this.assignRecords);
              };
            })(this);
            this.getMaxAirSpeedMissions = (function(_this) {
              return function(speed, opt) {
                if (opt == null) {
                  opt = 'GT';
                }
                return _this.service.getMaxAirSpeedMissions(speed, opt).then(_this.assignRecords);
              };
            })(this);
            this.getLatitudeMissions = (function(_this) {
              return function(latitude, opt) {
                if (opt == null) {
                  opt = 'GT';
                }
                return _this.service.getLatitudeMissions(latitude, opt).then(_this.assignRecords);
              };
            })(this);
            this.getLongitudeMissions = (function(_this) {
              return function(longitude, opt) {
                if (opt == null) {
                  opt = 'GT';
                }
                return _this.service.getLongitudeMissions(longitude, opt).then(_this.assignRecords);
              };
            })(this);
            this.sortCreatedAt = (function(_this) {
              return function() {};
            })(this);
            this.assignRecords = (function(_this) {
              return function(records) {
                _this.scope.records = records;
                return _this.scope.checkIfNextPage();
              };
            })(this);
            this.appendRecords = (function(_this) {
              return function(records) {
                return _this.scope.records = _this.scope.records.concat(records);
              };
            })(this);
            this.chooseDataSet = (function(_this) {
              return function() {
                if (_this.scope.missionDataSet === 'all') {
                  return _this.allMissions();
                }
                if (_this.scope.missionDataSet === 'mine') {
                  return _this.userMissions();
                }
              };
            })(this);
            this.filterDataSet = (function(_this) {
              return function(value, opt) {
                _this.scope.filterInProgress = true;
                if (_this.scope.filters.field.field === 'field_flightDuration') {
                  value *= 60;
                }
                _this.setFetchParamsFilter(value);
                if (_this.scope.missionDataSet === 'all') {
                  switch (_this.scope.filters.field.field) {
                    case 'field_maxGroundspeed':
                      return _this.getMaxGroundSpeedMissions(value, opt).then(_this.filterClear);
                    case 'field_flightDuration':
                      return _this.getDurationMissions(value, opt).then(_this.filterClear);
                    case 'field_maxAirspeed':
                      return _this.getMaxAirSpeedMissions(value, opt).then(_this.filterClear);
                    case 'field_maxAlt':
                      return _this.getMaxAltMissions(value, opt).then(_this.filterClear);
                    case 'field_latitude':
                      return _this.getLatitudeMissions(value, opt).then(_this.filterClear);
                    case 'field_longitude':
                      return _this.getLongitudeMissions(value, opt).then(_this.filterClear);
                    default:
                      return $log.debug("something is wrong");
                  }
                } else if (_this.scope.missionDataSet === 'mine') {
                  return _this.userMissions(_this.fetchParams).then(_this.filterClear);
                }
              };
            })(this);
            this.filterClear = (function(_this) {
              return function() {
                return _this.scope.filterInProgress = false;
              };
            })(this);
            this.setCreatedAt = (function(_this) {
              return function() {
                var fetchParams;
                fetchParams = _this.service.getFetchParams();
                fetchParams.order_dir = _this.createdAt;
                _this.service.createdAt = _this.createdAt;
                return $log.debug("sortDirection: ", _this.createdAt, " fetchParams: ", fetchParams);
              };
            })(this);
            this.nextPage = (function(_this) {
              return function() {
                var offset;
                if (_this.scope.busy) {
                  return false;
                }
                _this.scope.busy = true;
                offset = _this.fetchParams.page_offset;
                if (_this.fetchParams.page_offset === 0) {
                  offset = 1;
                }
                _this.fetchParams.page_offset = _this.fetchParams.page_size + offset;
                return _this.service.getMissions(_this.fetchParams).then(function(records) {
                  _this.scope.busy = false;
                  return _this.appendRecords(records);
                });
              };
            })(this);
            return this;
          }
        ],
        link: function($scope, element, attributes, controller) {
          $scope.$watch('missionDataSet', (function(_this) {
            return function(newValue, oldValue) {
              if (newValue !== oldValue) {
                return controller.chooseDataSet();
              }
            };
          })(this));
          $scope.tryFilterField = (function(_this) {
            return function(index) {
              $scope.dropDownIsOpen.field = false;
              return $scope.filters.field = controller.filterFields[index];
            };
          })(this);
          $scope.tryFilterOp = (function(_this) {
            return function(index) {
              $log.debug("tryfilterOp: ", index);
              $scope.dropDownIsOpen.opt = false;
              return $scope.filters.opt = controller.filterOpts[index];
            };
          })(this);
          $scope.tryFilterDataSet = (function(_this) {
            return function() {
              $scope.filtersActive = true;
              controller.filterDataSet($scope.filters.input, $scope.filters.opt.opt);
              return $scope.filters.dataset = "" + $scope.filters.field.title + " is " + $scope.filters.opt.humanize + " " + $scope.filters.input;
            };
          })(this);
          $scope.checkIfNextPage = function() {
            if ($scope.noInfiniteScroll) {
              return false;
            }
            return controller.nextPage();
          };
          $scope.toggleCreatedAt = (function(_this) {
            return function() {
              controller.createdAt = controller.createdAt === 'asc' ? 'desc' : 'asc';
              controller.setCreatedAt();
              return controller.chooseDataSet();
            };
          })(this);
          return ($('.form-control-input-clear')).bind('click', (function(_this) {
            return function(event) {
              if ($scope.filtersActive) {
                $scope.filtersActive = false;
                $scope.filterInProgress = true;
                $scope.filters.input = '';
                $scope.filters.dataset = '';
                controller.createdAt = 'asc';
                return controller.chooseDataSet().then(controller.filterClear);
              }
            };
          })(this));
        }
      };
    }
  ]);

}).call(this);
