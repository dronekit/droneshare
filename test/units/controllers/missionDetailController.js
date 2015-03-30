(function() {
  describe("missionDetailController", function() {
    beforeEach(module('app'));
    beforeEach(inject(function($rootScope, $controller, _$httpBackend_) {
      var routeParamsStub;
      loadJSONFixtures('user.json');
      loadJSONFixtures('mission.json');
      loadJSONFixtures('messages.geo.json');
      this.scope = $rootScope.$new();
      this.user = getJSONFixture('user.json');
      this.mission = getJSONFixture('mission.json');
      this.geojson = getJSONFixture('messages.geo.json');
      routeParamsStub = jasmine.createSpy('routeParamsStub');
      routeParamsStub.id = 218;
      this.userDetailController = $controller('missionDetailController', {
        '$scope': this.scope,
        '$routeParams': routeParamsStub
      });
      this.urlBase = 'https://api.droneshare.com/api/v1';
      this.httpBackend = _$httpBackend_;
      this.httpBackend.whenGET("" + this.urlBase + "/auth/user").respond(200, this.user);
      this.httpBackend.whenGET("" + this.urlBase + "/mission/" + routeParamsStub.id).respond(200, this.mission);
      return this.httpBackend.whenGET("" + this.urlBase + "/mission/" + routeParamsStub.id + "/messages.geo.json").respond(200, this.geojson);
    }));
    it('gets mission record by params', function() {
      expect(this.scope.record).toBeUndefined();
      this.scope.$apply();
      this.httpBackend.flush();
      return expect(this.scope.record).not.toBeUndefined();
    });
    describe('get_geojson', function() {
      it('gets geojson data at init', function() {
        expect(this.scope.geojson).toEqual({});
        this.scope.$apply();
        this.httpBackend.flush();
        return expect(this.scope.geojson).not.toEqual({});
      });
      return it('should set bounds', function() {
        expect(this.scope.bounds).toEqual({});
        this.scope.$apply();
        this.httpBackend.flush();
        expect(this.scope.bounds).not.toEqual({});
        expect(this.scope.bounds.southWest.lng).toEqual(this.geojson.bbox[0]);
        expect(this.scope.bounds.southWest.lat).toEqual(this.geojson.bbox[1]);
        expect(this.scope.bounds.northEast.lng).toEqual(this.geojson.bbox[3]);
        return expect(this.scope.bounds.northEast.lat).toEqual(this.geojson.bbox[4]);
      });
    });
    return describe('handle_fetch_response', function() {
      it('gets formats date to present to users', function() {
        var createdOn;
        this.scope.$apply();
        this.httpBackend.flush();
        createdOn = new Date(this.mission.createdOn);
        return expect(this.scope.record.dateString).toEqual("" + (createdOn.toDateString()) + " - " + (createdOn.toLocaleTimeString()));
      });
      return it('prepares data for social sharing', function() {
        this.scope.$apply();
        this.httpBackend.flush();
        expect(this.scope.$parent.ogImage).toEqual(this.mission.mapThumbnailURL);
        expect(this.scope.$parent.ogDescription).toEqual("" + this.mission.userName + " flew their drone in " + this.mission.summaryText + " for " + (Math.round(this.mission.flightDuration / 60)) + " minutes.");
        return expect(this.scope.$parent.ogTitle).toEqual("" + this.mission.userName + "'s mission");
      });
    });
  });

}).call(this);
