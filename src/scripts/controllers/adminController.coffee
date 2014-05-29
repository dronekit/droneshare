class Controller
  @$inject: ['$sce', '$scope', '$log', 'adminService']
  constructor: (@sce, @scope, @log, @adminService) ->
    @simType = "std/4/600"
    @lines = []
    @debugInfo = "(waiting for server...)"

    @log.debug("Starting log viewing")
    adminService.atmosphere.on("log", @onLog)

    # Async fetch of debugging info
    @adminService.getDebugInfo().then (results) =>
      @log.debug("Setting debug info")
      @debugInfo = results

    @startSim = () =>
      @log.debug("Running sim " + @simType)
      @adminService.startSim(@simType)

    @importOld = (count) =>
      @adminService.importOld(count)

    @runCommand = (cmd) =>
      @adminService.postId(cmd)

  onLog: (data) =>
    @log.info("Logmsg: " + data)
    # Keep the last 10 log entries
    @scope.$apply(() =>
      @lines.push(data.toString())
      @lines = @lines[-10..]
    )



#Controller.$inject = ['$scope', '$log', 'adminService']

angular.module('app').controller 'adminController', Controller
