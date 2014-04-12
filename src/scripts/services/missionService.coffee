class Service
  constructor: (@$log, @$http, @$routeParams) ->
    useLocalServer = $routeParams.localServer ? false
    base = if useLocalServer
      'http://localhost:8080'
    else
      'http://nestor.3dr.com'
    path = '/api/v1/mission'
    @urlBase = base + path
    console.log("urlBase: " + @urlBase)

  get: ->
    @$http.get(@urlBase)
    .then (results) ->
      results.data

  getMission: (id) ->
    @$http.get("#{@urlBase}/#{id}")
    .then (results) ->
      results.data

  getGeoJSON: (id) ->
    @$http.get("#{@urlBase}/#{id}/messages.geo.json")
    .then (results) ->
      results.data

  save: (mission) ->
    @$http.post("#{@urlBase}", mission)
    .error (results, status) ->
      {results, status}

angular.module('app').service 'missionService', ['$log', '$http', '$routeParams', Service]
