
class DetailController
  constructor: (@scope, @routeParams) ->
    # Useful for constructing sub urls in the HTML
    @urlBase = @service.urlId(@routeParams.id)
    @clear_error()
    @clear_success()

    @fetch_all_records = () =>
      @service.getId(@routeParams.id).then (results) =>
        @scope.record = results
        @record = results

    @fetch_all_records() # Prefetch at start

  # protected method, allow subclasses to set error title bars
  set_error: (message) =>
    @errors.push(message)

  clear_error: () =>
    @errors = []

  add_success: (message) =>
    @successes.push(message)

  clear_success: (message) =>
    @successes = []

class UserDetailController extends DetailController
  @$inject: ['$log', '$scope', '$routeParams', 'userService']
  constructor: (@log, scope, routeParams, @service) ->
    super(scope, routeParams)

class VehicleDetailController extends DetailController
  @$inject: ['$upload', '$log', '$scope', '$routeParams', 'vehicleService']
  constructor: (@upload, @log, scope, routeParams, @service) ->
    super(scope, routeParams)

    @uploading = false
    @upload_progress = 0

    @on_file_select = (files) =>
      @clear_error()
      c =
        url: @service.urlId(@routeParams.id) + '/missions'
        method: 'POST'
        file: files
      angular.extend(c, @service.config)
      @upload.upload(c)
      .progress((evt) =>
        if evt.total > 0
          @uploading = true
          progress = evt.loaded * 0.75 # We reserve last 1/4 for server time
          @upload_progress = parseInt(100.0 * progress / evt.total)
          @log.debug('percent: ' + parseInt(100.0 * evt.loaded / evt.total)))

      .success((data, status, headers, config) =>
        @log.info('success!')
        @add_success('Upload completed!')
        @uploading = false
        @fetch_all_records() # Add any newly created missions
        )
      .error((data, status, headers) =>
        @uploading = false
        @add_error('Upload failed')
        @log.error('upload failed: ' + result)
      )

class MissionDetailController
  @$inject: ['$modal', '$log', '$scope', '$routeParams', 'loadMission', 'loadGeoJson', 'missionService']
  constructor: (@modal, @log, @scope, @routeParams, @mission, @geojson, @resolvedObject) ->
    @urlBase = @resolvedObject.service.urlId(@routeParams.id)
    @log.debug("Setting mission")
    @log.debug(@mission)
    @scope.mission = @mission
    @scope.center = {}

    @log.debug("Setting geojson")
    # Bounding box MUST be in the GeoJSON and it must be 3 dimensional
    @scope.bounds =
      southWest:
        lng: @geojson.bbox[0]
        lat: @geojson.bbox[1]
      northEast:
        lng: @geojson.bbox[3]
        lat: @geojson.bbox[4]

    @scope.geojson =
      data: @geojson
      style:
        fillColor: "green"
        weight: 2
        color: 'black'
        dashArray: '3'
        fillOpacity: 0.7

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
    #@resolvedObject.service.get_parameters(@routeParams.id).then (httpResp) =>
      #@log.debug("Setting parameters")
      #@parameters = httpResp.data

    #@resolvedObject.service.get_plotdata(@routeParams.id).then (httpResp) =>
      #@log.debug("Setting parameters")
      #@scope.plotData = httpResp.data

angular.module('app').controller 'userDetailController', UserDetailController
angular.module('app').controller 'vehicleDetailController', VehicleDetailController
angular.module('app').controller 'missionDetailController', MissionDetailController
