class Controller
  @$inject: ['missionService']
  constructor: (@missionService) ->
    @setMissions()

  setMissions: =>
    params =
      order_by: "updatedOn"
      order_dir: "desc"
      page_size: "10"
    @missionService.get(params).then (results) =>
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
