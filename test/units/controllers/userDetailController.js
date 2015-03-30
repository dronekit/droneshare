(function() {
  describe("userDetailController", function() {
    beforeEach(module('app'));
    beforeEach(inject(function($rootScope, $controller, _$httpBackend_) {
      var routeParamsStub;
      loadJSONFixtures('user.json');
      this.scope = $rootScope.$new();
      this.user = getJSONFixture('user.json');
      this.authUser = angular.extend({
        loggedIn: true
      }, this.user);
      routeParamsStub = jasmine.createSpy('routeParamsStub');
      routeParamsStub.id = 219;
      this.userDetailController = $controller('userDetailController', {
        '$scope': this.scope,
        '$routeParams': routeParamsStub,
        'resolvedUser': this.user
      });
      this.urlBase = 'https://api.droneshare.com/api/v1';
      this.httpBackend = _$httpBackend_;
      this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(200, this.user);
      return this.httpBackend.whenGET("" + this.urlBase + "/user/" + routeParamsStub.id).respond(200, this.user);
    }));
    it('expects a resolved user object to be provided', function() {
      return expect(this.scope.record).not.toBeUndefined();
    });
    return describe('isMeOrAdmin', function() {
      it('knows if auth user is owner of current user record', function() {
        spyOn(this.userDetailController.authService, 'getUser').and.returnValue(this.authUser);
        this.scope.$apply();
        this.httpBackend.flush();
        return expect(this.userDetailController.isMe()).toBeTruthy();
      });
      return it('knows if auth user is owner of current record or an admin', function() {
        this.scope.$apply();
        this.httpBackend.flush();
        spyOn(this.userDetailController, 'isMe').and.returnValue(false);
        return expect(this.userDetailController.isMeOrAdmin()).not.toBeTruthy();
      });
    });
  });

}).call(this);
