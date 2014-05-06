
class DetailController
  constructor: (@scope, @routeParams) ->
    # Useful for constructing sub urls in the HTML
    @urlBase = @service.urlId(@routeParams.id)

    @service.getId(@routeParams.id).then (results) =>
      @record = results

class UserDetailController extends DetailController
  @$inject: ['$log', '$scope', '$routeParams', 'userService']
  constructor: (@log, scope, routeParams, @service) ->
    super(scope, routeParams)

class VehicleDetailController extends DetailController
  @$inject: ['$log', '$scope', '$routeParams', 'vehicleService']
  constructor: (@log, scope, routeParams, @service) ->
    super(scope, routeParams)

class MissionDetailController extends DetailController
  @$inject: ['$log', '$scope', '$routeParams', 'missionService']
  constructor: (@log, scope, routeParams, @service) ->
    super(scope, routeParams)

    @scope.center = {}  # Apparently required to use bounds
    @scope.bounds = {}

    # Prefetch params - FIXME - only fetch as needed?
    @service.get_parameters(@routeParams.id).then (httpResp) =>
      @log.debug("Setting parameters")
      @parameters = httpResp.data

    # Go ahead and fetch 'geojson' in case child directives (map) want it
    @service.get_geojson(@routeParams.id).then (httpResp) =>
      results = httpResp.data
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

angular.module('app').controller 'userDetailController', UserDetailController
angular.module('app').controller 'vehicleDetailController', VehicleDetailController
angular.module('app').controller 'missionDetailController', MissionDetailController
