(function() {
  var Controller,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Controller = (function() {
    Controller.$inject = ['$sce', '$scope', '$log', 'adminService'];

    function Controller(sce, scope, log, adminService) {
      this.sce = sce;
      this.scope = scope;
      this.log = log;
      this.adminService = adminService;
      this.onLog = __bind(this.onLog, this);
      this.simType = "std/4/600";
      this.lines = [];
      this.debugInfo = "(waiting for server...)";
      this.log.debug("Starting log viewing");
      adminService.atmosphere.on("log", this.onLog);
      this.adminService.getDebugInfo().then((function(_this) {
        return function(results) {
          _this.log.debug("Setting debug info");
          return _this.debugInfo = results;
        };
      })(this));
      this.startSim = (function(_this) {
        return function() {
          _this.log.debug("Running sim " + _this.simType);
          return _this.adminService.startSim(_this.simType);
        };
      })(this);
      this.importOld = (function(_this) {
        return function(count) {
          return _this.adminService.importOld(count);
        };
      })(this);
      this.runCommand = (function(_this) {
        return function(cmd) {
          return _this.adminService.postId(cmd);
        };
      })(this);
    }

    Controller.prototype.onLog = function(data) {
      this.log.info("Logmsg: " + data);
      return this.scope.$apply((function(_this) {
        return function() {
          _this.lines.push(data.toString());
          return _this.lines = _this.lines.slice(-10);
        };
      })(this));
    };

    return Controller;

  })();

  angular.module('app').controller('adminController', Controller);

}).call(this);
