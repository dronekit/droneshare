(function() {
  jasmine.getJSONFixtures().fixturesPath = '/base/test/fixtures';

  describe("missionService", function() {
    beforeEach(module('app'));
    beforeEach(inject(function($rootScope, _$httpBackend_, missionService) {
      loadJSONFixtures('dseries.json');
      loadJSONFixtures('mission.json');
      loadJSONFixtures('parameters.json');
      loadJSONFixtures('messages.geo.json');
      loadJSONFixtures('staticmap.json');
      this.fetchParams = {
        order_by: "createdAt",
        order_dir: "desc",
        page_size: "12"
      };
      this.urlBase = 'https://api.droneshare.com/api/v1';
      this.scope = $rootScope.$new();
      this.missionService = missionService;
      this.httpBackend = _$httpBackend_;
      this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond({
        "message": "You are not logged in"
      });
      return this.httpBackend.whenGET("" + this.urlBase + "/mission/staticMap").respond(getJSONFixture('staticmap.json'));
    }));
    it('should get missions', function() {
      var expected, negativeTestSuccess, notExpected, positiveTestSuccess;
      expected = getJSONFixture('missions.json');
      notExpected = [{}];
      this.httpBackend.expectGET("" + this.urlBase + "/mission").respond(expected);
      positiveTestSuccess = function(results) {
        expect(results).toEqual(expected);
        return results;
      };
      negativeTestSuccess = function(results) {
        expect(results).not.toEqual(notExpected);
        return results;
      };
      this.missionService.get().then(positiveTestSuccess).then(negativeTestSuccess);
      return this.httpBackend.flush();
    });
    it('should get a mission by id', function() {
      var expected, negativeTestSuccess, notExpected, positiveTestSuccess;
      expected = getJSONFixture('mission.json');
      notExpected = {};
      this.httpBackend.expectGET("" + this.urlBase + "/mission/4750").respond(expected);
      positiveTestSuccess = function(results) {
        expect(results).toEqual(expected);
        return results;
      };
      negativeTestSuccess = function(results) {
        expect(results).not.toEqual(notExpected);
        return results;
      };
      this.missionService.getId(4750).then(positiveTestSuccess).then(negativeTestSuccess);
      return this.httpBackend.flush();
    });
    it('should get plot data from a mission', function() {
      var expected, negativeTestSuccess, notExpected, positiveTestSuccess;
      expected = getJSONFixture('dseries.json');
      notExpected = [];
      this.httpBackend.expectGET("" + this.urlBase + "/mission/4750/dseries").respond(expected);
      positiveTestSuccess = function(results) {
        expect(results.data).toEqual(expected);
        return results;
      };
      negativeTestSuccess = function(results) {
        expect(results.data).not.toEqual(notExpected);
        return results;
      };
      this.missionService.get_plotdata(4750).then(positiveTestSuccess).then(negativeTestSuccess);
      return this.httpBackend.flush();
    });
    it('should get parameters from a mission', function() {
      var expected, negativeTestSuccess, notExpected, positiveTestSuccess;
      expected = getJSONFixture('parameters.json');
      notExpected = [];
      this.httpBackend.expectGET("" + this.urlBase + "/mission/4750/parameters.json").respond(expected);
      positiveTestSuccess = function(results) {
        expect(results.data).toEqual(expected);
        return results;
      };
      negativeTestSuccess = function(results) {
        expect(results.data).not.toEqual(notExpected);
        return results;
      };
      this.missionService.get_parameters(4750).then(positiveTestSuccess).then(negativeTestSuccess);
      return this.httpBackend.flush();
    });
    return it('should get geojson from a mission', function() {
      var expected, negativeTestSuccess, notExpected, positiveTestSuccess;
      expected = getJSONFixture('messages.geo.json');
      notExpected = [];
      this.httpBackend.expectGET("" + this.urlBase + "/mission/4750/messages.geo.json").respond(expected);
      positiveTestSuccess = function(results) {
        expect(results.data).toEqual(expected);
        return results;
      };
      negativeTestSuccess = function(results) {
        expect(results.data).not.toEqual(notExpected);
        return results;
      };
      this.missionService.get_geojson(4750).then(positiveTestSuccess).then(negativeTestSuccess);
      return this.httpBackend.flush();
    });
  });

}).call(this);
