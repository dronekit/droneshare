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
    @config =
      # FIXME - better to include in an auth header per RFC2617 Authorization: DroneApi apikey="blah.blah"
      #params:
      #  api_key: "eb34bd67.megadroneshare"
      headers:
        Authorization: 'DroneApi apikey="eb34bd67.megadroneshare"'

  urlBase: ->
    @apiBase + @endpoint

class AuthService extends DapiService
  endpoint: "auth"

class RESTService extends DapiService
  get: ->
    @log.debug("Getting all #{@endpoint}")
    @http.get(@urlBase(), @config)
    .then (results) ->
      results.data

  getId: (id) ->
    @log.debug("Getting #{@endpoint}/#{id}")
    @http.get("#{@urlBase()}/#{id}", @config)
    .then (results) ->
      results.data

  saveId: (id, obj) ->
    @log.debug("Saving #{@endpoint}/#{id}")
    @http.post("#{@urlBase()}/#{id}", obj, @config)
    .error (results, status) ->
      {results, status}

class UserService extends RESTService
  endpoint: "user"

class VehicleService extends RESTService
  endpoint: "vehicle"

class MissionService extends RESTService
  endpoint: "mission"

  getGeoJSON: (id) ->
    @http.get("#{@urlBase()}/#{id}/messages.geo.json", @config)
    .then (results) ->
      results.data


module = angular.module('app')
module.service 'missionService', MissionService
module.service 'userService', UserService
module.service 'vehicleService', VehicleService
module.service 'authService', AuthService
