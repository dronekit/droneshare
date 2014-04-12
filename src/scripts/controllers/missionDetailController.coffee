class Controller
  @$inject: ['$routeParams', 'missionService']
  constructor: (@routeParams, @missionService) ->
    @fetchMission()

  fetchMission: =>
    console.log("Getting mission " + @routeParams.id)
    @missionService.getId(@routeParams.id).then (results) =>
      @mission = results

angular.module('app').controller 'missionDetailController', Controller
