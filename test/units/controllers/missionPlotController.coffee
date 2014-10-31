describe "missionPlotController", ->
  beforeEach module 'app'
  beforeEach inject ($rootScope, $controller, _$httpBackend_) ->
    loadJSONFixtures 'user.json'
    loadJSONFixtures 'mission.json'
    loadJSONFixtures 'dseries.json'

    @scope = $rootScope.$new()
    @user = getJSONFixture 'user.json'
    @mission = getJSONFixture 'mission.json'
    @dseries = getJSONFixture 'dseries.json'

    routeParamsStub = jasmine.createSpy('routeParamsStub')
    routeParamsStub.id = 218

    @missionPlotController = $controller('missionPlotController', { '$scope': @scope, '$routeParams': routeParamsStub, 'missionData': @mission, 'plotData': @dseries })
    @urlBase = 'https://api.droneshare.com/api/v1'
    @httpBackend = _$httpBackend_
    @httpBackend.whenGET("#{@urlBase}/auth/user").respond 200, @user
    @httpBackend.whenGET("#{@urlBase}/mission/#{routeParamsStub.id}").respond 200, @mission
    @httpBackend.whenGET("#{@urlBase}/mission/#{routeParamsStub.id}/dseries").respond 200, @dseries

  it 'gets mission record as a resolved instance', ->
    expect(@scope.record).toEqual @mission

  it 'gets plot data as a resolved instance', ->
    expect(@scope.series).toEqual @dseries
