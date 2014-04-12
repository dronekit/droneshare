class Controller
  @$inject: ['$log', '$scope', '$routeParams', 'missionService']
  constructor: (@log, @scope, @routeParams, @missionService) ->
    @fetchMission()

  fetchMission: =>
    @missionService.getId(@routeParams.id).then (results) =>
      @mission = results

    # Go ahead and fetch 'geojson' in case child directives (map) want it
    @missionService.getGeoJSON(@routeParams.id).then (results) =>
      @log.debug("Setting geojson")
      @scope.geojson =
        data: results
        style:
          # FIXME - populate styles inside the JSON instead?
          fillColor: "green"
          weight: 2
          #opacity: 1
          color: 'black'
          dashArray: '3'
          fillOpacity: 0.7

angular.module('app').controller 'missionDetailController', Controller
