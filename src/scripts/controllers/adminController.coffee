class Controller
  @$inject: ['$scope', '$log', 'adminService']
  constructor: (@scope, @log, @adminService) ->
    @simType = "quick"
    @lines = []

    @log.debug("Starting log viewing")
    adminService.atmosphere.on("log", @onLog)

    # Async fetch of debugging info
    @adminService.getDebugInfo().then (results) =>
      @log.debug("Setting debug info")
      @scope.debugInfo = results

    @startSim = () =>
      @log.debug("Running sim " + @simType)
      @adminService.startSim(@simType)

    @importOld = (count) =>
      @adminService.importOld(count)

  onLog: (data) =>
    @log.info("Logmsg: " + data)
    # Keep the last 10 log entries
    @lines.push(data.toString())
    @lines = @lines[-10..]
    @scope.$apply()



#Controller.$inject = ['$scope', '$log', 'adminService']

angular.module('app').controller 'adminController', Controller
