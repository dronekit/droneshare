describe "userDetailController", ->
  beforeEach module 'app'
  beforeEach inject ($rootScope, $controller, _$httpBackend_) ->
    loadJSONFixtures('user.json')
    @scope = $rootScope.$new()
    @user = getJSONFixture('user.json')
    routeParamsStub = jasmine.createSpy('routeParamsStub')
    routeParamsStub.id = 219

    @userDetailController = $controller('userDetailController', { '$scope': @scope, '$routeParams': routeParamsStub })
    @urlBase = 'http://api.droneshare.com/api/v1'
    @httpBackend = _$httpBackend_
    @httpBackend.expectGET("#{@urlBase}/auth/user").respond 200, @user
    @httpBackend.expectGET("#{@urlBase}/user/#{routeParamsStub.id}").respond 200, @user

  it 'gets user detail by params', ->
    expect(@scope.record).toBeUndefined()
    @scope.$apply()
    @httpBackend.flush()
    expect(@scope.record).not.toBeUndefined()

  describe 'isMeOrAdmin', ->
    it 'knows if its me', ->
      @scope.$apply()
      @httpBackend.flush()
      expect(@userDetailController.isMe()).toBeTruthy()

    it 'knows if i\'m an admin', ->
      @scope.$apply()
      @httpBackend.flush()

      # force check of admin
      spyOn(@userDetailController, 'isMe').and.returnValue(false)
      expect(@userDetailController.isMeOrAdmin()).toBeTruthy()
