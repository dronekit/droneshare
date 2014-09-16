describe "vehicleDetailController", ->
  beforeEach module 'app'
  beforeEach inject ($rootScope, $controller, _$httpBackend_) ->
    loadJSONFixtures 'user.json'
    loadJSONFixtures 'vehicle.json'

    @scope = $rootScope.$new()
    @user = getJSONFixture('user.json')
    @vehicle = getJSONFixture('vehicle.json')

    routeParamsStub = jasmine.createSpy('routeParamsStub')
    routeParamsStub.id = 218

    @vehicleDetailController = $controller('vehicleDetailController', { '$scope': @scope, '$routeParams': routeParamsStub, 'resolvedVehicle': @vehicle })
    @urlBase = 'https://api.droneshare.com/api/v1'
    @httpBackend = _$httpBackend_
    @httpBackend.expectGET("#{@urlBase}/auth/user").respond 200, @user
    @httpBackend.expectGET("#{@urlBase}/vehicle/#{routeParamsStub.id}").respond 200, @vehicle

  it 'expects a resolved vehicle object to be provided', ->
    expect(@scope.record).not.toBeUndefined()
