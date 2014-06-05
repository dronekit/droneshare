

# Common code shared by all MDS controllers
class BaseController
  constructor: (@scope) ->
    @clear_error()
    @clear_success()

  # protected method, allow subclasses to set error title bars
  add_error: (message) =>
    @scope.errors.push(message)

  # protected method, allow subclasses to set error title bars
  set_error: (message) =>
    @clear_error()
    @scope.errors.push(message)

  # Set the error msg based on http response msg
  set_http_error: (results) =>
    console.log("got error #{results.status} #{results.statusText}")
    msg = if results.status == 404
      "Record not found" # Provide slightly friendlier text for this common case
    else
      results.statusText
    @set_error(msg)

  clear_error: () =>
    @scope.errors = []

  add_success: (message) =>
    @scope.successes.push(message)

  clear_success: (message) =>
    @scope.successes = []

  clear_all: () =>
    @clear_error()
    @clear_success()

class EmailConfirmController extends BaseController
  @$inject: ['$route', '$routeParams', '$log', '$scope', '$location', 'authService']
  constructor: (@route, @routeParams, @log, scope, @location, @service) ->
    super(scope)
    @do_email_confirm()

  do_email_confirm: () =>
    @service.email_confirm(@routeParams.id, @routeParams.verification).then((results) =>
      @add_success('Your email address is now confirmed')
    , (reason) =>
      @log.debug("Email confirm failed due to #{reason.statusText}")
      @set_http_error(reason)
    )

# Provides login information and operations for the GUI - typically instantiated at a root level on the page
class AuthController extends BaseController
  @$inject: ['$route', '$routeParams', '$log', '$scope', '$location', 'authService']
  constructor: (@route, @routeParams, @log, scope, @location, @service) ->
    super(scope)
    @login = ""
    @password = ""
    @email = ""
    @fullName = ""
    @wantEmails = true
    @user = null
    @getUser = @service.getUser

    @can_login = () =>
      @password.trim() != "" && @login.trim() != ""

    @can_create = () =>
      @password.trim() != "" && @login.trim() != "" && (@email ? "").trim() != "" && @fullName.trim() != ""

    # If defined, show to user as a presubmit warning (passwords do not match, too short, etc...)
    @get_create_warning = () =>
      if !@email?
        "Invalid email address"
      else if @password != ""
        if @password.length < 8
          "Password too short"
        else if !/\d/.test(@password)
          "Password must contain a digit"
      else
        null

    @do_login = () =>
      @service.login(@login, @password).then((results) =>
        @location.path("/") # Back to top of app
      , (reason) =>
        @log.debug("Login failed due to #{reason.statusText}")
        @set_http_error(reason)
      )

    @do_password_reset = () =>
      @service.password_reset(@login).then((results) =>
        @add_success('Password reset email sent...')
      , (reason) =>
        @log.debug("Password reset failed due to #{reason.statusText}")
        @set_http_error(reason)
      )

    @do_password_reset_confirm = () =>
      @service.password_reset_confirm(@routeParams.id, @routeParams.verification, @password).then((results) =>
        @add_success('Your password has been reset')
        @location.path("/") # Back to top of app
      , (reason) =>
        @log.debug("Password reset failed due to #{reason.statusText}")
        @set_http_error(reason)
      )

    @doCreate = () =>
      payload =
        login: @login
        password: @password
        email: @email
        fullName: @fullName
        wantEmails: @wantEmails

      @service.create(payload).then((results) =>
        @location.path("/") # Back to top of app
      , (reason) =>
        @log.debug("Not created due to #{reason.statusText}")
        @set_http_error(reason)
      )

    @do_logout = () =>
      @service.logout().then (results) =>
        # Redirect to root
        @location.path("/")

  isLoggedIn: =>
    @getUser().loggedIn

  isAnonymous: =>
    !@isLoggedIn()

  getError: ->
    return @service.getError()

# A droneapi client that gets lits of records
class MultiRecordController extends BaseController
  @$inject: ['$log', '$scope']
  constructor: (@log, @scope) ->
    super(scope)

  fetchRecords: =>
    @service.get(@fetchParams ? {}).then (results) =>
      @records = (@extendRecord(r) for r in results)
      @log.debug("Fetched #{@records.length} records")

  # Subclasses can override if they would like to modify the records that were returned by the server
  extendRecord: (rec) ->
    rec

  addRecord: (mission) =>
    @service.save(mission)
    .success (results) =>
      @error = ''
      @mission = {}

      fetchRecords()
    .error (results, status) =>
      if status is 403
        @error = results
    .then (results) ->
      results

class MissionController extends MultiRecordController
  @$inject: ['$log', '$scope', 'missionService']
  constructor: (log, scope, @service) ->
    @fetchParams =
      order_by: "updatedAt"
      order_dir: "desc"
      page_size: "12"
    super(log, scope)
    @fetchRecords() # FIXME - find a better way to control when/if we autofetch anything

  # Subclasses can override if they would like to modify the records that were returned by the server
  extendRecord: (rec) ->
    date = new Date(rec.createdOn)
    rec.dateString = date.toDateString()
    rec.text = rec.summaryText ? "Mission #{rec.id}"

    # Temp hack - server has some records encoded with "near " at the beginning
    # Remove this after next DB rebuild
    rec.text = rec.text.replace(/(?:near )?(.*)/, '$1')
    rec

class UserController extends MultiRecordController
  @$inject: ['$log', '$scope', 'userService']
  constructor: (log, scope, @service) ->
    super(log, scope)
    @fetchRecords() # FIXME - find a better way to control when/if we autofetch anything

class VehicleController extends MultiRecordController
  @$inject: ['$log', '$scope', 'vehicleService']
  constructor: (log, scope, @service) ->
    super(log, scope)
    log.debug('Not autofetching vehicles') # FIXME - find a better way to control when/if we autofetch anything

  add_vehicle: () =>
    # The JSON for this new vehicle
    v =
      name: "New vehicle"

    @service.append(v).then (results) =>
      # tell others they may want to refetch our vehicles
      @scope.$emit('vehicleAdded')

angular.module('app').controller 'missionController', MissionController
angular.module('app').controller 'vehicleController', VehicleController
angular.module('app').controller 'userController', UserController
angular.module('app').controller 'authController', AuthController
angular.module('app').controller 'emailConfirmController', EmailConfirmController

#
# Detail controllers (all in this file for the time being until I find the 'angular' way to share globals)
#

# A controller that shows just a single record
class DetailController extends BaseController
  constructor: (scope, @routeParams) ->
    super(scope)

    # Useful for constructing sub urls in the HTML
    @urlBase = @service.urlId(@routeParams.id)

    @fetch_record = () =>
      @clear_all()
      @service.getId(@routeParams.id).then (results) =>
        @handle_fetch_response(results)
      , (results) =>
        @set_http_error(results)

    # Save our record to the server
    @submit = () =>
      @clear_all()
      @service.putId(@routeParams.id, @get_record_for_submit()).then (results) =>
        @add_success('Updated')
        @handle_submit_response(results.data)
      , (results) =>
        @set_http_error(results)

    @fetch_record() # Prefetch at start

  # Subclasses can override if they would like to strip content out before submitting
  get_record_for_submit: =>
    @record

  # Normally the response to submit is used to update the local model, subclasses can override
  handle_submit_response: (data) =>
    @assign_record(data)

  # Normally the response to submit is used to update the local model, subclasses can override
  handle_fetch_response: (data) =>
    @assign_record(data)

  assign_record: (data) ->
    @scope.record = data # FIXME - I don't think this is necessary - this is the scope...
    @record = data
    @original_record = angular.copy(@record) # deep copy to compare against

class UserDetailController extends DetailController
  @$inject: ['$log', '$scope', '$routeParams', 'userService', 'authService']
  constructor: (@log, scope, routeParams, @service, @authService) ->
    super(scope, routeParams)

    @scope.$on('vehicleAdded', (event, args) =>
      @log.debug('fetching due to add')
      @fetch_record()
    )

    # Is this user the same as me?
    @isMe = () =>
      me = @authService.getUser()
      me.loggedIn && (@record?.login == me.login)

    # Is this user the same as me or am I at least an admin?
    @isMeOrAdmin = () =>
      @isMe() || @authService.getUser()?.isAdmin

    @scope.showEditForm = ->
      $('#user-details-form').toggleClass('hidden')

    # reset form
    @closeEditForm = ->
      @record = angular.copy(@original_record) # reset record to original values
      @scope.showEditForm()

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
        @fetch_record() # Add any newly created missions
        )
      .error((data, status, headers) =>
        @uploading = false
        if status == 406
          @add_error('The server found that flight boring...')
        else
          @add_error('Upload failed: ' + data)
      )

class MissionDetailController extends DetailController
  @$inject: ['$modal', '$log', '$scope', '$routeParams', 'missionService', '$rootScope']
  constructor: (@modal, @log, scope, routeParams, @service, @rootScope) ->
    super(scope, routeParams)
    @scope.urlBase = @urlBase # FIXME - is there a better way to pass this out to the html?
    @scope.center = {}
    @scope.bounds = {}
    @scope.geojson = {}

    @service.get_geojson(@routeParams.id).then (result) =>
      @log.debug("Setting geojson")
      @geojson = result
      @scope.geojson =
        data: @geojson
        style:
          fillColor: "green"
          weight: 2
          color: 'black'
          dashArray: '3'
          fillOpacity: 0.7

      # Bounding box MUST be in the GeoJSON and it must be 3 dimensional
      @scope.bounds =
        southWest:
          lng: @geojson.bbox[0]
          lat: @geojson.bbox[1]
        northEast:
          lng: @geojson.bbox[3]
          lat: @geojson.bbox[4]

    # Show the parameters modal in the correct location
    @show_parameters = () =>
      @log.info('opening parameters')
      dialog = @modal.open
        templateUrl: '/views/mission/parameters-modal.html'
        controller: 'missionParameterController as controller'
        # size: 'lg'
        windowClass: 'parameters-modal fade'

    # Show the data plot modal in the correct location
    @show_plot = () =>
      @log.info('opening data plot')
      dialog = @modal.open
        templateUrl: '/views/mission/plot-modal.html'
        controller: 'missionPlotController as controller'
        # backdrop: 'static'
        # windowClass: 'parameters-modal fade'

      # FIXME - use resolve to pass in state to the child
      #resolve: {
      #  items: function () {
      #    return $scope.items;
      #  }
      #}

      # Do something like the following if we want to get results back
      #dialog.result.then(function (selectedItem) {
      #  $scope.selected = selectedItem;
      #}, function () {
      #  $log.info('Modal dismissed at: ' + new Date());
      #});

  # Subclasses can override if they would like to strip content out before submitting
  get_record_for_submit: =>
    # The server doesn't understand this yet
    delete @record.viewPrivacy
    delete @record.createdOn
    delete @record.updatedOn
    @record

  handle_submit_response: (data) ->
    # We just ignore the response (for snappy gui action)

  # We update open social data so facebook shows nice content
  handle_fetch_response: (data) ->
    super(data)
    @log.info('Setting root scope')
    @rootScope.ogImage = data.mapThumbnailURL
    @rootScope.ogDescription = data.userName + " flew their drone in " +
      data.summaryText + " for " + Math.round(data.flightDuration / 60) + " minutes."
    @rootScope.ogTitle = data.userName + "'s flight"

class MissionParameterController extends BaseController
  @$inject: ['$log', '$scope', '$routeParams', 'missionService']
  constructor: (@log, scope, @routeParams, @service) ->
    super(scope)

    # Prefetch params - FIXME - only fetch as needed?
    @service.get_parameters(@routeParams.id).then (httpResp) =>
      @log.debug("Setting parameters")
      @parameters = httpResp.data

class MissionPlotController extends BaseController
  @$inject: ['$log', '$scope', '$routeParams', 'missionService']
  constructor: (@log, scope, @routeParams, @service) ->
    super(scope)

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
    @log.debug("Fetching plot data for " + @routeParams.id)
    @service.get_plotdata(@routeParams.id).then (httpResp) =>
      @log.debug("Setting plot")
      @scope.plotData = httpResp.data

angular.module('app').controller 'userDetailController', UserDetailController
angular.module('app').controller 'vehicleDetailController', VehicleDetailController
angular.module('app').controller 'missionDetailController', MissionDetailController
angular.module('app').controller 'missionParameterController', MissionParameterController
angular.module('app').controller 'missionPlotController', MissionPlotController

