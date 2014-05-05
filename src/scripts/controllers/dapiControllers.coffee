
# Provides login information and operations for the GUI - typically instantiated at a root level on the page
class AuthController
  @$inject: ['$route', '$log', '$scope', '$location', 'authService']
  constructor: (@route, @log, @scope, @location, @service) ->
    @login = ""
    @password = ""
    @password2 = ""
    @email = ""
    @fullName = ""
    @user = null
    @error = null

    @scope.$on('$viewContentLoaded', (event) =>
      @log.info('viewContentLoaded')
    )

    @service.checkLogin().then (user) =>
      @user = user

    @can_login = () =>
      @password.trim() != "" && @login.trim() != ""

    @can_create = () =>
      @password == @password2 && @password.trim() != "" && @login.trim() != "" && (@email ? "").trim() != "" && @fullName.trim() != ""

    # If defined, show to user as a presubmit warning (passwords do not match, too short, etc...)
    @get_create_warning = () =>
      if !@email?
        "Invalid email address"
      else if (@password2 != "" && @password != @password2)
        "Passwords do not match"
      else
        null

    @do_login = () =>
      @service.login(@login, @password).then((results) =>
        @user = results.data
        @error = null
        @location.path("/") # Back to top of app
      , (reason) =>
        @log.debug("Login failed due to #{reason.statusText}")
        @error = reason.statusText
      )

    @doCreate = () =>
      @service.create(@login, @password, @email, @fullName).then((results) =>
        @user = results.data
        @error = null
        @location.path("/") # Back to top of app
      , (reason) =>
        @log.debug("Not created due to #{reason.statusText}")
        @error = reason.statusText
      )

    @doLogout = () =>
      @service.logout().then (results) =>
        # Redirect to root
        @location.path("/")
        @error = null

class DapiController
  constructor: () ->
    @fetchRecords()

  fetchRecords: =>
    @service.get(@fetchParams ? {}).then (results) =>
      @records = results

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
