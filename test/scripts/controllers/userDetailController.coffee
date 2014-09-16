describe "userDetailController", ->
  beforeEach module 'app'
  beforeEach inject ($rootScope, $controller, _$httpBackend_) ->
    loadJSONFixtures('user.json')
    @scope = $rootScope.$new()
    @user = getJSONFixture('user.json')
    @authUser = angular.extend({loggedIn: true}, @user)
    routeParamsStub = jasmine.createSpy('routeParamsStub')
    routeParamsStub.id = 219

    @userDetailController = $controller('userDetailController', { '$scope': @scope, '$routeParams': routeParamsStub, 'resolvedUser': @user })
    @urlBase = 'https://api.droneshare.com/api/v1'
    @httpBackend = _$httpBackend_
    @httpBackend.whenGET("#{@urlBase}/auth/user").respond 200, @user
    @httpBackend.whenGET("#{@urlBase}/user/#{routeParamsStub.id}").respond 200, @user

  it 'expects a resolved user object to be provided', ->
    expect(@scope.record).not.toBeUndefined()

  describe 'isMeOrAdmin', ->
    it 'knows if auth user is owner of current user record', ->
      spyOn(@userDetailController.authService, 'getUser').and.returnValue(@authUser)

      @scope.$apply()
      @httpBackend.flush()

      expect(@userDetailController.isMe()).toBeTruthy()

    it 'knows if auth user is owner of current record or an admin', ->
      @scope.$apply()
      @httpBackend.flush()

      # force check of admin
      spyOn(@userDetailController, 'isMe').and.returnValue(false)
      expect(@userDetailController.isMeOrAdmin()).not.toBeTruthy()
