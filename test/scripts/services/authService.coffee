jasmine.getJSONFixtures().fixturesPath = '/base/test/fixtures'

describe "authService", ->
  beforeEach module 'app'

  beforeEach inject ($rootScope, $controller, _$httpBackend_, authService) ->
    loadJSONFixtures 'user.json'
    @user         = getJSONFixture 'user.json'
    @scope        = $rootScope.$new()
    @urlBase      = 'https://api.3drobotics.com/api/v1'
    @authService  = authService
    @httpBackend  = _$httpBackend_

  describe 'initialize', ->
    beforeEach ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond @user

    it 'user is logged out on initialize',  ->
      expect(@authService.user.loggedIn).not.toBeTruthy()

      @scope.$apply()
      @httpBackend.flush()

      expect(@authService.user.loggedIn).toBeTruthy()

    it 'checks if a user is currently logged in', ->
      spyOn(@authService, 'setLoggedIn')

      @scope.$apply()
      @httpBackend.flush()

      expect(@authService.setLoggedIn).toHaveBeenCalledWith @user

  describe 'logout', ->
    beforeEach ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond @user
      @scope.$apply()
      @httpBackend.flush()

    it 'logs user out', ->
      expect(@authService.user.loggedIn).toBeTruthy()
      @authService.logout()
      expect(@authService.user.loggedIn).not.toBeTruthy()

    it 'should call the api action /logout', ->
      spyOn(@authService, 'postId').and.callThrough()
      @authService.logout()
      expect(@authService.postId).toHaveBeenCalledWith 'logout'

  describe 'create', ->
    it 'should post payload to API /create', ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond @user
      spyOn(@authService, 'postId').and.callThrough()
      payload = jasmine.createSpy('payload')
      @authService.create(payload)
      expect(@authService.postId).toHaveBeenCalledWith 'create', payload

    it 'should login user upon creation', ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond 401, {}
      @httpBackend.expectPOST("#{@urlBase}/auth/create").respond @user

      spyOn(@authService, 'setLoggedIn')
      payload = jasmine.createSpy('payload')
      @authService.create(payload)

      @scope.$apply()
      @httpBackend.flush()

      expect(@authService.setLoggedIn).toHaveBeenCalled()

  describe 'login', ->
    beforeEach ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond 401, {}

    it 'posts user credentials to API', ->
      @httpBackend.expectPOST("#{@urlBase}/auth/login").respond @user

      spyOn(@authService, 'postId').and.callThrough()
      @authService.login 'mrpollo', 'password'

      @scope.$apply()
      @httpBackend.flush()

      expect(@authService.postId).toHaveBeenCalled()

    # currently there is logic in place to send this headers
    # but after careful review its not POSTing data as form-urlendcode
    # instead is doing app/js with utf8
    xit 'posts user credentials to API with a form content type', ->
      @httpBackend.expectPOST("#{@urlBase}/auth/login", {}, (headers) ->
        return headers['Content-Type'] == 'application/x-wwww-form-urlencoded'
      ).respond @user

      @authService.login 'mrpollo', 'password'

      @scope.$apply()
      @httpBackend.flush()

  describe 'password_reset', ->
    it 'calls API /pwreset with loginName', ->
      spyOn(@authService, 'postId')
      @authService.password_reset 'mrpollo'
      expect(@authService.postId).toHaveBeenCalled()

  describe 'password_reset_confirm', ->
    beforeEach ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond 401, {}

    it 'confirms password reset via token', ->
      @httpBackend.expectPOST("#{@urlBase}/auth/pwreset/mrpollo/token").respond @user
      spyOn(@authService, 'postId').and.callThrough()

      @authService.password_reset_confirm 'mrpollo', 'token', 'password'

      @scope.$apply()
      @httpBackend.flush()

      expect(@authService.postId).toHaveBeenCalledWith "pwreset/mrpollo/token", JSON.stringify('password')

  describe 'email_confirm', ->
    beforeEach ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond 401, {}

    it 'should confirm user email', ->
      spyOn(@authService, 'postId')
      @authService.email_confirm 'mrpollo', 'token'
      expect(@authService.postId).toHaveBeenCalledWith "emailconfirm/mrpollo/token", {}

  describe 'setLoggedIn', ->
    beforeEach ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond @user

    it 'should flag @user.loggedIn as true and return user', ->
      spyOn(@authService, 'setLoggedIn').and.callThrough()
      expect(@user.loggedIn).toBeUndefined()
      @authService.setLoggedIn(@user)
      expect(@authService.user.loggedIn).toBeTruthy()
      expect(@authService.user.login).toEqual @user.login

  describe 'setLoggedOut', ->
    it 'should flag @user.loggedIn as false', ->
      spyOn(@authService, 'setLoggedOut').and.callThrough()
      @authService.setLoggedIn(@user)
      expect(@authService.user.loggedIn).toBeTruthy()
      @authService.setLoggedOut()
      expect(@authService.user.loggedIn).not.toBeTruthy()

  describe 'getUser', ->
    beforeEach ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond @user

    it 'should return current user object', ->
      @authService.user = @user
      @scope.$apply()
      expect(@authService.getUser()).toEqual @user

  describe 'checkLogin', ->
    afterEach ->
      @httpBackend.verifyNoOutstandingExpectation()
      @httpBackend.verifyNoOutstandingRequest()

    it 'should login is user if succesful', ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond @user
      spyOn(@authService, 'setLoggedIn')
      @authService.checkLogin()

      @scope.$apply()
      @httpBackend.flush()

      expect(@authService.setLoggedIn).toHaveBeenCalledWith @user

    it 'should call setLoggedOut on error', ->
      @httpBackend.whenGET("#{@urlBase}/auth/user").respond(401, '')
      spyOn(@authService, 'setLoggedOut')
      @authService.checkLogin()

      @scope.$apply()
      @httpBackend.flush()

      expect(@authService.setLoggedOut).toHaveBeenCalled()
