(function() {
  jasmine.getJSONFixtures().fixturesPath = '/base/test/fixtures';

  describe("authService", function() {
    beforeEach(module('app'));
    beforeEach(inject(function($rootScope, $controller, _$httpBackend_, authService) {
      loadJSONFixtures('user.json');
      this.user = getJSONFixture('user.json');
      this.scope = $rootScope.$new();
      this.urlBase = 'https://api.droneshare.com/api/v1';
      this.authService = authService;
      return this.httpBackend = _$httpBackend_;
    }));
    describe('initialize', function() {
      beforeEach(function() {
        return this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(this.user);
      });
      it('user is logged out on initialize', function() {
        expect(this.authService.user.loggedIn).not.toBeTruthy();
        this.scope.$apply();
        this.httpBackend.flush();
        return expect(this.authService.user.loggedIn).toBeTruthy();
      });
      return it('checks if a user is currently logged in', function() {
        spyOn(this.authService, 'setLoggedIn');
        this.scope.$apply();
        this.httpBackend.flush();
        return expect(this.authService.setLoggedIn).toHaveBeenCalledWith(this.user);
      });
    });
    describe('logout', function() {
      beforeEach(function() {
        this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(this.user);
        this.scope.$apply();
        return this.httpBackend.flush();
      });
      it('logs user out', function() {
        expect(this.authService.user.loggedIn).toBeTruthy();
        this.authService.logout();
        return expect(this.authService.user.loggedIn).not.toBeTruthy();
      });
      return it('should call the api action /logout', function() {
        spyOn(this.authService, 'postId').and.callThrough();
        this.authService.logout();
        return expect(this.authService.postId).toHaveBeenCalledWith('logout');
      });
    });
    describe('create', function() {
      it('should post payload to API /create', function() {
        var payload;
        this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(this.user);
        spyOn(this.authService, 'postId').and.callThrough();
        payload = jasmine.createSpy('payload');
        this.authService.create(payload);
        return expect(this.authService.postId).toHaveBeenCalledWith('create', payload);
      });
      return it('should login user upon creation', function() {
        var payload;
        this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(401, {});
        this.httpBackend.expectPOST("" + this.urlBase + "/auth/create").respond(this.user);
        spyOn(this.authService, 'setLoggedIn');
        payload = jasmine.createSpy('payload');
        this.authService.create(payload);
        this.scope.$apply();
        this.httpBackend.flush();
        return expect(this.authService.setLoggedIn).toHaveBeenCalled();
      });
    });
    describe('login', function() {
      beforeEach(function() {
        return this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(401, {});
      });
      it('posts user credentials to API', function() {
        this.httpBackend.expectPOST("" + this.urlBase + "/auth/login").respond(this.user);
        spyOn(this.authService, 'postId').and.callThrough();
        this.authService.login('mrpollo', 'password');
        this.scope.$apply();
        this.httpBackend.flush();
        return expect(this.authService.postId).toHaveBeenCalled();
      });
      return xit('posts user credentials to API with a form content type', function() {
        this.httpBackend.expectPOST("" + this.urlBase + "/auth/login", {}, function(headers) {
          return headers['Content-Type'] === 'application/x-wwww-form-urlencoded';
        }).respond(this.user);
        this.authService.login('mrpollo', 'password');
        this.scope.$apply();
        return this.httpBackend.flush();
      });
    });
    describe('password_reset', function() {
      return it('calls API /pwreset with loginName', function() {
        spyOn(this.authService, 'postId');
        this.authService.password_reset('mrpollo');
        return expect(this.authService.postId).toHaveBeenCalled();
      });
    });
    describe('password_reset_confirm', function() {
      beforeEach(function() {
        return this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(401, {});
      });
      return it('confirms password reset via token', function() {
        this.httpBackend.expectPOST("" + this.urlBase + "/auth/pwreset/mrpollo/token").respond(this.user);
        spyOn(this.authService, 'postId').and.callThrough();
        this.authService.password_reset_confirm('mrpollo', 'token', 'password');
        this.scope.$apply();
        this.httpBackend.flush();
        return expect(this.authService.postId).toHaveBeenCalledWith("pwreset/mrpollo/token", JSON.stringify('password'));
      });
    });
    describe('email_confirm', function() {
      beforeEach(function() {
        return this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(401, {});
      });
      return it('should confirm user email', function() {
        spyOn(this.authService, 'postId');
        this.authService.email_confirm('mrpollo', 'token');
        return expect(this.authService.postId).toHaveBeenCalledWith("emailconfirm/mrpollo/token", {});
      });
    });
    describe('setLoggedIn', function() {
      beforeEach(function() {
        return this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(this.user);
      });
      return it('should flag @user.loggedIn as true and return user', function() {
        spyOn(this.authService, 'setLoggedIn').and.callThrough();
        expect(this.user.loggedIn).toBeUndefined();
        this.authService.setLoggedIn(this.user);
        expect(this.authService.user.loggedIn).toBeTruthy();
        return expect(this.authService.user.login).toEqual(this.user.login);
      });
    });
    describe('setLoggedOut', function() {
      return it('should flag @user.loggedIn as false', function() {
        spyOn(this.authService, 'setLoggedOut').and.callThrough();
        this.authService.setLoggedIn(this.user);
        expect(this.authService.user.loggedIn).toBeTruthy();
        this.authService.setLoggedOut();
        return expect(this.authService.user.loggedIn).not.toBeTruthy();
      });
    });
    describe('getUser', function() {
      beforeEach(function() {
        return this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(this.user);
      });
      return it('should return current user object', function() {
        this.authService.user = this.user;
        this.scope.$apply();
        return expect(this.authService.getUser()).toEqual(this.user);
      });
    });
    return describe('checkLogin', function() {
      afterEach(function() {
        this.httpBackend.verifyNoOutstandingExpectation();
        return this.httpBackend.verifyNoOutstandingRequest();
      });
      it('should login is user if succesful', function() {
        this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(this.user);
        spyOn(this.authService, 'setLoggedIn');
        this.authService.checkLogin();
        this.scope.$apply();
        this.httpBackend.flush();
        return expect(this.authService.setLoggedIn).toHaveBeenCalledWith(this.user);
      });
      return it('should call setLoggedOut on error', function() {
        this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(401, '');
        spyOn(this.authService, 'setLoggedOut');
        this.authService.checkLogin();
        this.scope.$apply();
        this.httpBackend.flush();
        return expect(this.authService.setLoggedOut).toHaveBeenCalled();
      });
    });
  });

}).call(this);
