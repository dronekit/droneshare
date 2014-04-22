class Controller
  @$inject: ['$scope', '$log', 'adminService']
  constructor: (@scope, @log, @adminService) ->
    @simType = "quick"
    @lines = []

    adminService.atmosphere.on("log", @onLog)

  onLog: (data) =>
    @log.info("Logmsg: " + data)
    # Keep the last 10 log entries
    @lines.push(data.toString())
    @lines = @lines[-10..]
    @scope.$apply()

  @startSim: () =>
    @adminService.startSim(@simType)

#Controller.$inject = ['$scope', '$log', 'adminService']

angular.module('app').controller 'adminController', Controller
