describe "missionPlotController", ->
  beforeEach module 'app'
  beforeEach inject ($rootScope, $controller, _$httpBackend_) ->
    loadJSONFixtures 'user.json'
    loadJSONFixtures 'dseries.json'

    @scope = $rootScope.$new()
    @user = getJSONFixture 'user.json'
    @dseries = getJSONFixture 'dseries.json'

    routeParamsStub = jasmine.createSpy('routeParamsStub')
    routeParamsStub.id = 218

    @missionPlotController = $controller('missionPlotController', { '$scope': @scope, '$routeParams': routeParamsStub })
    @urlBase = 'http://api.droneshare.com/api/v1'
    @httpBackend = _$httpBackend_
    @httpBackend.expectGET("#{@urlBase}/auth/user").respond 200, @user
    @httpBackend.expectGET("#{@urlBase}/mission/#{routeParamsStub.id}/dseries").respond 200, @dseries

  it 'gets mission record plot data by params', ->
    expect(@scope.plotData).toEqual {}
    @scope.$apply()
    @httpBackend.flush()
    expect(@scope.plotData).not.toEqual {}

  it 'sets options for flot directive', ->
    expect(@scope.plotOptions.xaxis.mode).toEqual 'time'
    expect(@scope.plotOptions.xaxis.timeformat).toEqual '%M:%S'
    expect(@scope.plotOptions.zoom.interactive).toBeTruthy()
    expect(@scope.plotOptions.pan.interactive).toBeTruthy()
