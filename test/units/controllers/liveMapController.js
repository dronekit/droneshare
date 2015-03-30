(function() {
  jasmine.getJSONFixtures().fixturesPath = '/base/test/fixtures';

  describe("liveMapController", function() {
    beforeEach(function() {
      return window.logos = {
        parent: '/images/3drobotics.png',
        son: '/images/droneshare.png',
        vehicleMarkerActive: '/images/vehicle-marker-active.png',
        vehicleMarkerInactive: '/images/vehicle-marker-inactive.png'
      };
    });
    beforeEach(module('app'));
    beforeEach(inject(function($rootScope, $controller, _$httpBackend_, _atmosphere_) {
      loadJSONFixtures('user.json');
      loadJSONFixtures('staticmap.json');
      this.scope = $rootScope.$new();
      this.atmosphere = _atmosphere_;
      this.liveMapController = $controller('liveMapController', {
        '$scope': this.scope
      });
      this.urlBase = 'https://api.droneshare.com/api/v1';
      this.httpBackend = _$httpBackend_;
      this.httpBackend.expectGET("" + this.urlBase + "/auth/user").respond(200, getJSONFixture('user.json'));
      return this.httpBackend.whenGET("" + this.urlBase + "/mission/staticMap").respond(getJSONFixture('staticmap.json'));
    }));
    it('should set scope.tiles', function() {
      this.scope.$apply();
      return expect(this.scope.tiles).not.toBeUndefined();
    });
    it('should set scope.layers', function() {
      this.scope.$apply();
      return expect(this.scope.layers).not.toBeUndefined();
    });
    it('should check if current user is logged in', function() {
      this.scope.$apply();
      this.httpBackend.flush();
      return expect(this.scope.auth.user.loggedIn).toBeTruthy();
    });
    it('should connect to all atmosphere services', function() {
      spyOn(this.liveMapController, 'connectAtmo');
      this.scope.$apply();
      this.httpBackend.flush();
      return expect(this.liveMapController.connectAtmo).toHaveBeenCalled();
    });
    it('should disconnect from all atmosphere  services on scope destroy', function() {
      spyOn(this.liveMapController, 'disconnectAtmo');
      this.scope.$apply();
      this.httpBackend.flush();
      this.scope.$destroy();
      return expect(this.liveMapController.disconnectAtmo).toHaveBeenCalled();
    });
    return describe('atmosphere', function() {
      beforeEach(function() {
        loadJSONFixtures('atmosphere.att.json');
        loadJSONFixtures('atmosphere.delete.json');
        loadJSONFixtures('atmosphere.mystery.json');
        loadJSONFixtures('atmosphere.start.json');
        loadJSONFixtures('atmosphere.stop.json');
        return loadJSONFixtures('atmosphere.update.json');
      });
      describe('onMissionUpdate', function() {
        beforeEach(function() {
          spyOn(this.liveMapController, 'onMissionUpdate').and.callThrough();
          return spyOn(this.liveMapController, 'updateVehicle').and.callThrough();
        });
        it('should handle start frames', function() {
          var fakeMissionStart, vehicleKey;
          fakeMissionStart = getJSONFixture('atmosphere.start.json').data;
          vehicleKey = this.liveMapController.vehicleKey(fakeMissionStart.missionId);
          expect(this.scope.vehicleMarkers[vehicleKey]).toBeUndefined();
          this.liveMapController.onMissionUpdate(fakeMissionStart);
          expect(this.liveMapController.updateVehicle).toHaveBeenCalled();
          return expect(this.scope.vehicleMarkers[vehicleKey].payload.id).toEqual(fakeMissionStart.missionId);
        });
        return describe('update frame messages', function() {
          beforeEach(function() {
            return this.fakeMissionUpdate = getJSONFixture('atmosphere.update.json').data;
          });
          it('should create markers if it doesn\'t yet exist', function() {
            var vehicleKey;
            vehicleKey = this.liveMapController.vehicleKey(this.fakeMissionUpdate.missionId);
            expect(this.scope.vehicleMarkers[vehicleKey]).toBeUndefined();
            this.liveMapController.onMissionUpdate(this.fakeMissionUpdate);
            return expect(this.scope.vehicleMarkers[vehicleKey].payload.id).toEqual(this.fakeMissionUpdate.missionId);
          });
          it('should update markers', function() {
            var fakeMissionStart, lat, lng, vehicleKey;
            fakeMissionStart = getJSONFixture('atmosphere.start.json').data;
            vehicleKey = this.liveMapController.vehicleKey(fakeMissionStart.missionId);
            expect(this.fakeMissionUpdate.missionId).toEqual(fakeMissionStart.missionId);
            expect(this.scope.vehicleMarkers[vehicleKey]).toBeUndefined();
            this.liveMapController.onMissionUpdate(fakeMissionStart);
            expect(this.scope.vehicleMarkers[vehicleKey].payload.id).toEqual(fakeMissionStart.missionId);
            lat = this.scope.vehicleMarkers[vehicleKey].lat;
            lng = this.scope.vehicleMarkers[vehicleKey].lng;
            this.liveMapController.onMissionUpdate(this.fakeMissionUpdate);
            expect(this.scope.vehicleMarkers[vehicleKey].lat).not.toEqual(lat);
            return expect(this.scope.vehicleMarkers[vehicleKey].lng).not.toEqual(lng);
          });
          return it('should zoom to the current user vehicle', function() {
            var fakeMissionStart, me, vehicleKey;
            spyOn(this.liveMapController, 'zoomToVehicle');
            this.scope.$apply();
            this.httpBackend.flush();
            me = this.liveMapController.authService.getUser();
            fakeMissionStart = getJSONFixture('atmosphere.start.json').data;
            vehicleKey = this.liveMapController.vehicleKey(fakeMissionStart.missionId);
            this.liveMapController.onMissionUpdate(fakeMissionStart);
            expect(this.scope.vehicleMarkers[vehicleKey]).not.toBeUndefined();
            return expect(this.liveMapController.zoomToVehicle).toHaveBeenCalled();
          });
        });
      });
      describe('onMissionDelete', function() {
        return it('should remove vehicle marker', function() {
          var fakeMissionStart, fakeMissionStop, vehicleKey;
          fakeMissionStop = getJSONFixture('atmosphere.stop.json').data;
          fakeMissionStart = getJSONFixture('atmosphere.start.json').data;
          vehicleKey = this.liveMapController.vehicleKey(fakeMissionStart.missionId);
          expect(fakeMissionStop.missionId).toEqual(fakeMissionStart.missionId);
          expect(this.scope.vehicleMarkers[vehicleKey]).toBeUndefined();
          this.liveMapController.onMissionUpdate(fakeMissionStart);
          expect(this.scope.vehicleMarkers[vehicleKey]).not.toBeUndefined();
          this.liveMapController.onMissionDelete(fakeMissionStop);
          return expect(this.scope.vehicleMarkers[vehicleKey]).toBeUndefined();
        });
      });
      describe('updateVehicleMessage', function() {
        return it('should update marker popup', function() {
          loadJSONFixtures('atmosphere.mystery.json');
          spyOn(this.liveMapController, 'updateMarkerPopup');
          this.liveMapController.updateVehicleMessage(getJSONFixture('atmosphere.mystery.json').data);
          return expect(this.liveMapController.updateMarkerPopup).toHaveBeenCalled();
        });
      });
      return describe('onAttitude', function() {
        return it('should update marker angle', function() {
          var fakeAttitude, fakeMissionStart, vehicleKey;
          loadJSONFixtures('atmosphere.start.json');
          loadJSONFixtures('atmosphere.att.json');
          fakeMissionStart = getJSONFixture('atmosphere.start.json').data;
          fakeAttitude = getJSONFixture('atmosphere.att.json').data;
          vehicleKey = this.liveMapController.vehicleKey(fakeMissionStart.missionId);
          this.liveMapController.onMissionUpdate(fakeMissionStart);
          expect(this.scope.vehicleMarkers[vehicleKey]).not.toBeUndefined();
          this.liveMapController.onAttitude(fakeAttitude);
          return expect(this.scope.vehicleMarkers[vehicleKey].iconAngle).toEqual(fakeAttitude.payload.yaw);
        });
      });
    });
  });

}).call(this);
