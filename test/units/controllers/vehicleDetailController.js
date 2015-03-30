(function() {
  describe("vehicleDetailController", function() {
    beforeEach(module('app'));
    beforeEach(inject(function($rootScope, $controller, _$httpBackend_) {
      var routeParamsStub;
      loadJSONFixtures('user.json');
      loadJSONFixtures('vehicle.json');
      this.scope = $rootScope.$new();
      this.user = getJSONFixture('user.json');
      this.vehicle = getJSONFixture('vehicle.json');
      routeParamsStub = jasmine.createSpy('routeParamsStub');
      routeParamsStub.id = 218;
      this.vehicleDetailController = $controller('vehicleDetailController', {
        '$scope': this.scope,
        '$routeParams': routeParamsStub,
        'resolvedVehicle': this.vehicle
      });
      this.urlBase = 'https://api.droneshare.com/api/v1';
      this.httpBackend = _$httpBackend_;
      this.httpBackend.expectGET("" + this.urlBase + "/auth/user").respond(200, this.user);
      return this.httpBackend.expectGET("" + this.urlBase + "/vehicle/" + routeParamsStub.id).respond(200, this.vehicle);
    }));
    return it('expects a resolved vehicle object to be provided', function() {
      return expect(this.scope.record).not.toBeUndefined();
    });
  });

}).call(this);
