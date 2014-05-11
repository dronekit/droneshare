
# Provides login information and operations for the GUI - typically instantiated at a root level on the page
class AuthController
  @$inject: ['$route', '$log', '$scope', '$location', 'authService']
  constructor: (@route, @log, @scope, @location, @service) ->
    @login = ""
    @password = ""
    @email = ""
    @fullName = ""
    @wantEmails = true
    @user = null
    @error = null
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
        @error = null
        @location.path("/") # Back to top of app
      , (reason) =>
        @log.debug("Login failed due to #{reason.statusText}")
        @error = reason.statusText
      )

    @doCreate = () =>
      payload =
        login: @login
        password: @password
        email: @email
        fullName: @fullName
        wantEmails: @wantEmails

      @service.create(payload).then((results) =>
        @error = null
        @location.path("/") # Back to top of app
      , (reason) =>
        @log.debug("Not created due to #{reason.statusText}")
        @error = reason.statusText
      )

    @do_logout = () =>
      @service.logout().then (results) =>
        # Redirect to root
        @location.path("/")
        @error = null

  isLoggedIn: ->
    return if @getUser().loggedIn then true else false

  isAnonymous: ->
    return if @isLoggedIn() then false else true

class DapiController

  constructor: () ->
    @fetchRecords()

  fetchRecords: =>
    @service.service.get(@fetchParams ? {}).then (results) =>
      @records = (@extendRecord(r) for r in results)
      console.log("Fetched #{@records.length} records")

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

class MissionController extends DapiController
  @$inject: ['missionService']
  constructor: (@service) ->
    @fetchParams =
      order_by: "updatedOn"
      order_dir: "desc"
      page_size: "10"
    super()

  # Subclasses can override if they would like to modify the records that were returned by the server
  extendRecord: (rec) ->
    date = new Date(rec.createdOn)
    rec.dateString = date.toDateString()
    rec.text = rec.summaryText ? "Mission #{rec.id}"
    rec

class UserController extends DapiController
  @$inject: ['userService']
  constructor: (@service) ->
    super()

class VehicleController extends DapiController
  @$inject: ['vehicleService']
  constructor: (@service) ->
    super()

angular.module('app').controller 'missionController', MissionController
angular.module('app').controller 'vehicleController', VehicleController
angular.module('app').controller 'userController', UserController
angular.module('app').controller 'authController', AuthController
