(function() {
  describe("missionPlotController", function() {
    beforeEach(module('app'));
    beforeEach(inject(function($rootScope, $controller, _$httpBackend_) {
      var routeParamsStub;
      loadJSONFixtures('user.json');
      loadJSONFixtures('mission.json');
      loadJSONFixtures('dseries.json');
      this.scope = $rootScope.$new();
      this.user = getJSONFixture('user.json');
      this.mission = getJSONFixture('mission.json');
      this.dseries = getJSONFixture('dseries.json');
      routeParamsStub = jasmine.createSpy('routeParamsStub');
      routeParamsStub.id = 218;
      this.missionPlotController = $controller('missionPlotController', {
        '$scope': this.scope,
        '$routeParams': routeParamsStub,
        'missionData': this.mission,
        'plotData': this.dseries
      });
      this.urlBase = 'https://api.droneshare.com/api/v1';
      this.httpBackend = _$httpBackend_;
      this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(200, this.user);
      this.httpBackend.whenGET("" + this.urlBase + "/mission/" + routeParamsStub.id).respond(200, this.mission);
      return this.httpBackend.whenGET("" + this.urlBase + "/mission/" + routeParamsStub.id + "/dseries").respond(200, this.dseries);
    }));
    it('gets mission record as a resolved instance', function() {
      return expect(this.scope.record).toEqual(this.mission);
    });
    return it('gets plot data as a resolved instance', function() {
      return expect(this.scope.series).toEqual(this.dseries);
    });
  });

}).call(this);
