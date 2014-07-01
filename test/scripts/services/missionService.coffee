jasmine.getJSONFixtures().fixturesPath = '/base/test/fixtures'

describe "missionService", ->
  beforeEach module 'app'

  beforeEach ->
    @fetchParams =
      order_by: "createdAt"
      order_dir: "desc"
      page_size: "12"

    @urlBase = 'http://api.droneshare.com/api/v1'

  it 'should get missions', inject ['$httpBackend', 'missionService', ($httpBackend, missionService) ->
    loadJSONFixtures('missions.json')
    expected = getJSONFixture('missions.json')
    notExpected = [{}]

    $httpBackend.expectGET("#{@urlBase}/auth/user").respond({"message":"You are not logged in"})
    $httpBackend.expectGET("#{@urlBase}/mission").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results).not.toEqual notExpected
      results

    missionService.get().then(positiveTestSuccess).then(negativeTestSuccess)

    $httpBackend.flush()
  ]

  it 'should get a mission by id', inject ['$httpBackend', 'missionService', ($httpBackend, missionService) ->
    loadJSONFixtures('mission.json')
    expected = getJSONFixture('mission.json')
    notExpected = {}

    $httpBackend.expectGET("#{@urlBase}/auth/user").respond({"message":"You are not logged in"})
    $httpBackend.expectGET("#{@urlBase}/mission/4750").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results).not.toEqual notExpected
      results

    missionService.getId(4750).then(positiveTestSuccess).then(negativeTestSuccess)

    $httpBackend.flush()
  ]

  it 'should get plot data from a mission', inject ['$httpBackend', 'missionService', ($httpBackend, missionService) ->
    loadJSONFixtures('dseries.json')
    expected = getJSONFixture('dseries.json')
    notExpected = []

    $httpBackend.expectGET("#{@urlBase}/auth/user").respond({"message":"You are not logged in"})
    $httpBackend.expectGET("#{@urlBase}/mission/4750/dseries").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results.data).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results.data).not.toEqual notExpected
      results

    missionService.get_plotdata(4750).then(positiveTestSuccess).then(negativeTestSuccess)

    $httpBackend.flush()
  ]

  it 'should get parameters from a mission', inject ['$httpBackend', 'missionService', ($httpBackend, missionService) ->
    loadJSONFixtures('parameters.json')
    expected = getJSONFixture('parameters.json')
    notExpected = []

    $httpBackend.expectGET("#{@urlBase}/auth/user").respond({"message":"You are not logged in"})
    $httpBackend.expectGET("#{@urlBase}/mission/4750/parameters.json").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results.data).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results.data).not.toEqual notExpected
      results

    missionService.get_parameters(4750).then(positiveTestSuccess).then(negativeTestSuccess)

    $httpBackend.flush()
  ]

  it 'should get geojson from a mission', inject ['$httpBackend', 'missionService', ($httpBackend, missionService) ->
    loadJSONFixtures('messages.geo.json')
    expected = getJSONFixture('messages.geo.json')
    notExpected = []

    $httpBackend.expectGET("#{@urlBase}/auth/user").respond({"message":"You are not logged in"})
    $httpBackend.expectGET("#{@urlBase}/mission/4750/messages.geo.json").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results).not.toEqual notExpected
      results

    missionService.get_geojson(4750).then(positiveTestSuccess).then(negativeTestSuccess)

    $httpBackend.flush()
  ]
