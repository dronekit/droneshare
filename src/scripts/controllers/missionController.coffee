class Controller
  @$inject: ['$scope', 'missionService']
  constructor: (@scope, @missionService) ->
    @setMissions()

  setMissions: =>
    @missionService.get().then (results) =>
      @missions = results

  insertMission: (mission) =>
    @missionService.save(mission)
    .success (results) =>
      @error = ''
      @mission = {}

      setMissions()
    .error (results, status) =>
      if status is 403
        @error = results
    .then (results) ->
      results

angular.module('app').controller 'missionController', Controller
