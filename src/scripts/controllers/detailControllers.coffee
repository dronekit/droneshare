
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
  @$inject: ['$upload', '$log', '$scope', '$routeParams', 'vehicleService']
  constructor: (@upload, @log, scope, routeParams, @service) ->
    super(scope, routeParams)

    @on_file_select = (files) =>
      c =
        url: @service.urlId(@routeParams.id) + '/missions'
        method: 'POST'
        file: files
      c = angular.extend(c, @service.config)
      @upload.upload(c)
      .progress((evt) =>
        @log.debug('percent: ' + parseInt(100.0 * evt.loaded / evt.total)))
      .success((data, status, headers, config) =>
        @log.info('success!'))
      .error((result) =>
        @log.error('upload failed: ' + result)
      )

class MissionDetailController extends DetailController
  @$inject: ['$modal', '$log', '$scope', '$routeParams', 'missionService']
  constructor: (@modal, @log, scope, routeParams, @service) ->
    super(scope, routeParams)

    @scope.center = {}  # Apparently required to use bounds
    @scope.bounds = {}

    @scope.plotOptions =
      xaxis :
        mode : "time"
        timeformat : "%M:%S"
      zoom :
        interactive : true
      pan :
        interactive : true
    @scope.plotData = {}

    # Prefetch params - FIXME - only fetch as needed?
    @service.get_parameters(@routeParams.id).then (httpResp) =>
      @log.debug("Setting parameters")
      @parameters = httpResp.data

    @service.get_plotdata(@routeParams.id).then (httpResp) =>
      @log.debug("Setting parameters")
      @scope.plotData = httpResp.data

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
