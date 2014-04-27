class Controller
  @$inject: ['$log', '$scope', '$routeParams', 'missionService']
  constructor: (@log, @scope, @routeParams, @missionService) ->
    @fetchMission()
    @scope.center = {}  # Apparently required to use bounds
    @scope.bounds = {}

  fetchMission: =>
    @missionService.getId(@routeParams.id).then (results) =>
      @mission = results

    # Go ahead and fetch 'geojson' in case child directives (map) want it
    @missionService.getGeoJSON(@routeParams.id).then (results) =>
      @log.debug("Setting geojson")

      # Bounding box MUST be in the GeoJSON and it must be 3 dimensional
      bbox = results.bbox
      @scope.bounds =
        southWest:
          lng: bbox[0]
          lat: bbox[1]
        northEast:
          lng: bbox[3]
          lat: bbox[4]

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
