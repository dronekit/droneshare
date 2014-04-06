class Service
	urlBase = 'http://localhost:8080/api/v1/mission'

	constructor: (@$log, @$http) ->

	get: ->
		@$http.get(urlBase)
		.then (results) ->
			results.data

	getMission: (id) ->
		@$http.get("#{urlBase}/#{id}")
		.then (results) ->
			results.data

	save: (mission) ->
		@$http.post("#{urlBase}", mission)
		.error (results, status) ->
			{results, status}

angular.module('app').service 'missionService', ['$log', '$http', Service]