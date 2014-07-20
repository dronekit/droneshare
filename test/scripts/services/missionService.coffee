jasmine.getJSONFixtures().fixturesPath = '/base/test/fixtures'

describe "missionService", ->
  beforeEach module 'app'

  beforeEach inject ($rootScope, _$httpBackend_, missionService) ->
    loadJSONFixtures('dseries.json')
    loadJSONFixtures('mission.json')
    loadJSONFixtures('parameters.json')
    loadJSONFixtures('messages.geo.json')
    loadJSONFixtures('staticmap.json')

    @fetchParams =
      order_by: "createdAt"
      order_dir: "desc"
      page_size: "12"

    @urlBase = 'https://api.droneshare.com/api/v1'
    @scope = $rootScope.$new()
    @missionService = missionService
    @httpBackend = _$httpBackend_

    @httpBackend.whenGET("#{@urlBase}/auth/user").respond({"message":"You are not logged in"})
    @httpBackend.whenGET("#{@urlBase}/mission/staticMap").respond(getJSONFixture('staticmap.json'))

  it 'should get missions', ->
    expected = getJSONFixture('missions.json')
    notExpected = [{}]

    @httpBackend.expectGET("#{@urlBase}/mission").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results).not.toEqual notExpected
      results

    @missionService.get().then(positiveTestSuccess).then(negativeTestSuccess)

    @httpBackend.flush()

  it 'should get a mission by id', ->
    expected = getJSONFixture('mission.json')
    notExpected = {}

    @httpBackend.expectGET("#{@urlBase}/mission/4750").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results).not.toEqual notExpected
      results

    @missionService.getId(4750).then(positiveTestSuccess).then(negativeTestSuccess)

    @httpBackend.flush()

  it 'should get plot data from a mission', ->
    expected = getJSONFixture('dseries.json')
    notExpected = []

    @httpBackend.expectGET("#{@urlBase}/mission/4750/dseries").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results.data).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results.data).not.toEqual notExpected
      results

    @missionService.get_plotdata(4750).then(positiveTestSuccess).then(negativeTestSuccess)

    @httpBackend.flush()

  it 'should get parameters from a mission', ->
    expected = getJSONFixture('parameters.json')
    notExpected = []

    @httpBackend.expectGET("#{@urlBase}/mission/4750/parameters.json").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results.data).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results.data).not.toEqual notExpected
      results

    @missionService.get_parameters(4750).then(positiveTestSuccess).then(negativeTestSuccess)

    @httpBackend.flush()

  it 'should get geojson from a mission', ->
    expected = getJSONFixture('messages.geo.json')
    notExpected = []

    @httpBackend.expectGET("#{@urlBase}/mission/4750/messages.geo.json").respond(expected)

    positiveTestSuccess = (results) ->
      expect(results.data).toEqual expected
      results

    negativeTestSuccess = (results) ->
      expect(results.data).not.toEqual notExpected
      results

    @missionService.get_geojson(4750).then(positiveTestSuccess).then(negativeTestSuccess)

    @httpBackend.flush()
