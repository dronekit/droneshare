
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
    #useLocalServer = true
    base = if useLocalServer
      'http://localhost:8080'
    else
      'http://api.3dr.com'
    path = '/api/v1/'
    @apiBase = base + path
    @log.debug("Creating service " + @urlBase())

    # If set, this string is the human friendly error message about our last server error
    @error = null

    @config =
      withCredentials: true # Needed to send cookies
      useXDomain: true # needed to send cookies in POST
      # FIXME - better to include in an auth header per RFC2617 Authorization: DroneApi apikey="blah.blah"
      #params:
      #  api_key: "userkey.appkey"
      headers:
        Authorization: 'DroneApi apikey="' + apiKey + '"'

  urlBase: ->
    @apiBase + @endpoint

  getError: =>
    @error

class RESTService extends DapiService
  get: (params = {}) ->
    @log.debug("Getting all #{@endpoint}")
    cfg =
      params: params
    angular.extend(cfg, @config)
    @http.get(@urlBase(), cfg)
    .then (results) ->
      results.data

  # Return a URL that points to the specified ID
  urlId: (id) ->
    "#{@urlBase()}/#{id}"

  # Async read the specified ID
  getId: (id) ->
    @log.debug("Getting #{@endpoint}/#{id}")
    c = angular.extend({}, @config)
    @http.get(@urlId(id), c)
    .then (results) ->
      results.data

  putId: (id, obj, c) =>
    @log.debug("Saving #{@endpoint}/#{id}")
    c = angular.extend(c ? {}, @config)
    @http.put("#{@urlBase()}/#{id}", obj, c)

  postId: (id, obj, c) =>
    @log.debug("Posting to #{@endpoint}/#{id}")
    c = angular.extend(c ? {}, @config)
    @http.post("#{@urlBase()}/#{id}", obj, c)

  # Dynamically create a new record
  append: (obj, c) =>
    @log.debug("Appending to #{@endpoint}")
    c = angular.extend(c ? {}, @config)
    @http.put("#{@urlBase()}", obj, c)

class AuthService extends RESTService

  @$inject: ['$log', '$http', '$routeParams']
  constructor: (log, http, routeParams) ->
    super(log, http, routeParams)
    @setLoggedOut() # Preinit user
    @checkLogin() # Do an initial fetch

  endpoint: "auth"

  logout: () ->
    @setLoggedOut()
    @postId("logout")

  create: (payload) ->
    @log.debug("Attempting create for #{payload}")
    @postId("create", payload)
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
    @postId("login", {}, config)
    .success (results) =>
      @log.debug("Logged in!")
      @setLoggedIn(results)
    .error (results, status) =>
      @log.debug("Not logged in #{results}, #{status}")
      @setLoggedOut()

  password_reset: (loginName) ->
    @log.debug("Attempting password reset for #{loginName}")
    @postId("pwreset/#{loginName}", {})

  password_reset_confirm: (loginName, token, newPassword) ->
    @log.debug("Attempting password confirm for #{loginName}")
    @postId("pwreset/#{loginName}/#{token}", JSON.stringify(newPassword))
    .success (results) =>
      @log.debug("Password reset complete!")
      @setLoggedIn(results)

  email_confirm: (loginName, token) ->
    @log.debug("Attempting email confirm for #{loginName}")
    @postId("emailconfirm/#{loginName}/#{token}", {})

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
      @error = null
      @setLoggedIn(results)
    , (results) =>
      @log.error("Login check failed #{results.status}: #{results.statusText}")
      if results.status == 0
        @error = "DroneAPI server is offline, please try again later."
      @setLoggedOut


class UserService extends RESTService
  endpoint: "user"

class VehicleService extends RESTService
  endpoint: "vehicle"

class MissionService extends RESTService
  @$inject: ['$log', '$http', '$routeParams', 'atmosphere', 'authService']
  constructor: (log, http, routeParams, @atmosphere, @authService) ->
    super(log, http, routeParams)

  endpoint: "mission"

  atmosphere_connect: () =>
    request =
      url: @urlBase() + '/live'

    angular.extend(request, @config)
    angular.extend(request, atmosphereOptions)
    if @authService.getUser().login?
      request.headers.login = @authService.getUser()?.login
    @atmosphere.init(request)

  atmosphere_disconnect: () =>
    @atmosphere.close()

  get_parameters: (id) ->
    c = angular.extend({}, @config)
    @http.get("#{@urlBase()}/#{id}/parameters.json", c)
    .success (results) ->
      results.data

  get_plotdata: (id) ->
    c = angular.extend({}, @config)
    @http.get("#{@urlBase()}/#{id}/dseries", c)
    .success (results) ->
      results.data

  get_geojson: (id) ->
    c = angular.extend({}, @config)
    @http.get("#{@urlBase()}/#{id}/messages.geo.json", c)
    .then (results) ->
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
    @postId("sim/" + typ)

  importOld: (count) =>
    @log.info("importing " + count)
    @postId("import/" + count)

  getDebugInfo: () =>
    @getId("debugInfo")

module = angular.module('app')
module.service 'missionService', MissionService
module.service 'userService', UserService
module.service 'vehicleService', VehicleService
module.service 'authService', AuthService
module.service 'adminService', AdminService
