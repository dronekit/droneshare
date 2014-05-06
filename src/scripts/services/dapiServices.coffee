
apiKey = "eb34bd67.megadroneshare"

atmosphereOptions =
  contentType : 'application/json'
  transport : 'websocket'
  reconnectInterval : 5000
  enableXDR: true
  timeout : 60000
  fallbackTransport: 'jsonp' # Server might have issues with 'long-polling'
  headers:
    api_key: apiKey
  #onError: (resp) =>
  #  @log.error("Atmosphere error: #{resp}")
  #onTransportFailure: (msg, resp) =>
  #  @log.error("Transport failure #{msg} #{resp}")
  #onOpen: (resp) =>
  #  @log.info("Got open response #{resp.status}")

class DapiService
  @$inject: ['$log', '$http', '$routeParams']
  constructor: (@log, @http, routeParams) ->
    useLocalServer = routeParams.local ? false
    base = if useLocalServer
      'http://localhost:8080'
    else
      'http://nestor.3dr.com'
    path = '/api/v1/'
    @apiBase = base + path
    @log.debug("Creating service " + @apiBase)
    @config =
      withCredentials: true # Needed to send cookies
      useXDomain: true # needed to send cookies in POST
      # FIXME - better to include in an auth header per RFC2617 Authorization: DroneApi apikey="blah.blah"
      #params:
      #  api_key: "eb34bd67.megadroneshare"
      headers:
        Authorization: 'DroneApi apikey="' + apiKey + '"'

  urlBase: ->
    @apiBase + @endpoint

class RESTService extends DapiService
  get: (params = {}) ->
    @log.debug("Getting all #{@endpoint}")
    cfg = @config
    cfg.params = params

    @http.get(@urlBase(), cfg)
    .then (results) ->
      results.data

  # Return a URL that points to the specified ID
  urlId: (id) ->
    "#{@urlBase()}/#{id}"

  # Async read the specified ID
  getId: (id) ->
    @log.debug("Getting #{@endpoint}/#{id}")
    @http.get(@urlId(id), @config)
    .then (results) ->
      results.data

  saveId: (id, obj, c) =>
    @log.debug("Saving #{@endpoint}/#{id}")
    c = angular.extend(c ? {}, @config)
    @http.post("#{@urlBase()}/#{id}", obj, c)

class AuthService extends RESTService

  @$inject: ['$log', '$http', '$routeParams']
  constructor: (log, http, routeParams) ->
    super(log, http, routeParams)
    @setLoggedOut() # Preinit user
    @checkLogin() # Do an initial fetch

  endpoint: "auth"

  logout: () ->
    @setLoggedOut()
    @saveId("logout")

  create: (loginName, password, email, fullName) ->
    @log.debug("Attempting create for #{loginName}")
    payload =
      login: loginName
      password: password
      email: email
      fullName: fullName

    @saveId("create", payload)
    .success (results) =>
      @log.debug("Created in!")
      @setLoggedIn(results)

  login: (loginName, password) ->
    # Use a form style post
    config =
      headers:
        'Content-Type': 'application/x-www-form-urlencoded'
      params:
        login: loginName
        password: password
    @log.debug("Attempting login for #{loginName}")
    @saveId("login", {}, config)
    .success (results) =>
      @log.debug("Logged in!")
      @setLoggedIn(results)
    .error (results, status) =>
      @log.debug("Not logged in #{results}, #{status}")
      @setLoggedOut()

  # Returns the updated user record
  setLoggedIn: (userRecord) =>
    @user = userRecord
    @user.loggedIn = true
    @user

  setLoggedOut: () =>
    @user =
      loggedIn: false

  getUser: () =>
    @user

  checkLogin: () ->
    @getId("user")
    .then (results) =>
      @log.debug("login complete!")
      @setLoggedIn(results)


class UserService extends RESTService
  endpoint: "user"

class VehicleService extends RESTService
  endpoint: "vehicle"

class MissionService extends RESTService
  @$inject: ['$log', '$http', '$routeParams', 'atmosphere']
  constructor: (log, http, routeParams, @atmosphere) ->
    super(log, http, routeParams)

    request =
      url: @urlBase() + '/live'

    angular.extend(request, @config)
    angular.extend(request, atmosphereOptions)
    @atmosphere.init(request)

  endpoint: "mission"

  get_parameters: (id) ->
    @http.get("#{@urlBase()}/#{id}/parameters.json", @config)
    .success (results) ->
      results.data

  get_geojson: (id) ->
    @http.get("#{@urlBase()}/#{id}/messages.geo.json", @config)
    .success (results) ->
      results.data

# Server admin operations - not useful to users/developers
class AdminService extends RESTService
  @$inject: ['$log', '$http', '$routeParams', 'atmosphere']
  constructor: (log, http, routeParams, @atmosphere) ->
    super(log, http, routeParams)

    request =
      url: @urlBase() + '/log'

    angular.extend(request, @config)
    angular.extend(request, atmosphereOptions)
    @atmosphere.init(request)

  endpoint: "admin"

  startSim: (typ) =>
    @log.info("Service starting sim " + typ)
    @saveId("sim/" + typ)

  importOld: (count) =>
    @log.info("importing " + count)
    @saveId("import/" + count)

  getDebugInfo: () =>
    @getId("debugInfo")

module = angular.module('app')
module.service 'missionService', MissionService
module.service 'userService', UserService
module.service 'vehicleService', VehicleService
module.service 'authService', AuthService
module.service 'adminService', AdminService
