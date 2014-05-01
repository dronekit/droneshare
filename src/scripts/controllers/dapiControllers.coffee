
# Provides login information and operations for the GUI - typically instantiated at a root level on the page
class AuthController
  @$inject: ['authService']
  constructor: (@service) ->
    @login = ""
    @password = ""

    @doLogin = () =>
      @service.login(@login, @password)


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
