class Controller
  @$inject: ['$scope', '$routeParams', 'missionService']
  constructor: (@scope, @routeParams, @missionService) ->
    @setMissions()

  setMissions: =>
    console.log("Getting mission " + @routeParams.id)
    @missionService.getMission(@routeParams.id).then (results) =>
      @mission = results

angular.module('app').controller 'missionDetailController', Controller
