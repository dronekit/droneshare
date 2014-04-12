class Controller
  constructor: (@$log, @$routeParams, @missionService) ->
    setMissions = =>
      console.log("Getting mission " + $routeParams.id)
      @missionService.getMission($routeParams.id).then (results) =>
        @mission = results

    setMissions()

angular.module('app').controller 'missionDetailController', ['$log', '$routeParams', 'missionService', Controller]
