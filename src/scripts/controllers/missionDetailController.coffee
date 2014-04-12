class Controller
  @$inject: ['$scope']
  constructor: (@scope, @routeParams, @missionService) ->
    @setMissions()

  setMissions: =>
    console.log("Getting mission " + @routeParams.id)
    @missionService.getMission(@routeParams.id).then (results) =>
      @mission = results

angular.module('app').controller 'missionDetailController', ['$scope', '$routeParams', 'missionService', Controller]
