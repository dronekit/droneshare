class DapiService
  @$inject: ['$http', '$routeParams']
  constructor: (@http, routeParams) ->
    useLocalServer = routeParams.localServer ? false
    base = if useLocalServer
      'http://localhost:8080'
    else
      'http://nestor.3dr.com'
    path = '/api/v1/'
    @apiBase = base + path

  urlBase: ->
    @apiBase + @endpoint

  get: ->
    @http.get(@urlBase())
    .then (results) ->
      results.data

  getId: (id) ->
    @http.get("#{@urlBase()}/#{id}")
    .then (results) ->
      results.data

  saveId: (id, mission) ->
    @http.post("#{@urlBase()}/#{id}", mission)
    .error (results, status) ->
      {results, status}


class MissionService extends DapiService
  endpoint: "mission"

  getGeoJSON: (id) ->
    @http.get("#{@urlBase()}/#{id}/messages.geo.json")
    .then (results) ->
      results.data


angular.module('app').service 'missionService', MissionService
