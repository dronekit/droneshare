class Controller
  constructor: (@$log, @missionService) ->
    setMissions = =>
      @missionService.getMission(1).then (results) =>
        @mission = results

    setMissions()

angular.module('app').controller 'missionDetailController', ['$log', 'missionService', Controller]
