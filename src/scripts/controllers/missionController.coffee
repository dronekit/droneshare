class Controller
  @$inject: ['missionService', 'atmosphere']
  constructor: (@missionService, atmosphereService) ->
    request =
      url: 'http://localhost:8080/api/v1/mission/live?login=root&password=fish4403&api_key=eb34bd67.megadroneshare',
      contentType : 'application/json',
      transport : 'websocket',
      reconnectInterval : 5000,
      enableXDR: true,
      timeout : 60000
    @atmosphere = atmosphereService.init(request)
    @setMissions()

  setMissions: =>
    params =
      order_by: "updatedOn"
      order_dir: "desc"
      page_size: "10"
    @missionService.get(params).then (results) =>
      @missions = results

  insertMission: (mission) =>
    @missionService.save(mission)
    .success (results) =>
      @error = ''
      @mission = {}

      setMissions()
    .error (results, status) =>
      if status is 403
        @error = results
    .then (results) ->
      results

angular.module('app').controller 'missionController', Controller
