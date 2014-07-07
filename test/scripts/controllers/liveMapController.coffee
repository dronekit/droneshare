jasmine.getJSONFixtures().fixturesPath = '/base/test/fixtures'

describe "liveMapController", ->
  beforeEach ->
    window.logos =
      parent: '/images/3drobotics.png'
      son: '/images/droneshare.png'
      vehicleMarkerActive: '/images/vehicle-marker-active.png'
      vehicleMarkerInactive: '/images/vehicle-marker-inactive.png'

  beforeEach module 'app'
  beforeEach inject ($rootScope, $controller, _$httpBackend_, _atmosphere_) ->
    loadJSONFixtures('user.json')
    @scope = $rootScope.$new()
    @atmosphere = _atmosphere_

    @liveMapController = $controller('liveMapController', { '$scope': @scope })
    @urlBase = 'http://api.droneshare.com/api/v1'
    @httpBackend = _$httpBackend_
    @httpBackend.expectGET("#{@urlBase}/auth/user").respond 200, getJSONFixture('user.json')

  it 'should check if current user is logged in', ->
    @scope.$apply()
    @httpBackend.flush()

    expect(@scope.auth.user.loggedIn).toBeTruthy()

  it 'should connect to all atmosphere services', ->
    spyOn(@liveMapController, 'connectAtmo')

    @scope.$apply()
    @httpBackend.flush()

    expect(@liveMapController.connectAtmo).toHaveBeenCalled()

  it 'should disconnect from all atmosphere  services on scope destroy', ->
    spyOn(@liveMapController, 'disconnectAtmo')

    @scope.$apply()
    @httpBackend.flush()
    @scope.$destroy()

    expect(@liveMapController.disconnectAtmo).toHaveBeenCalled()

  describe 'atmosphere', ->
    beforeEach ->
      loadJSONFixtures 'atmosphere.att.json'
      loadJSONFixtures 'atmosphere.delete.json'
      loadJSONFixtures 'atmosphere.mystery.json'
      loadJSONFixtures 'atmosphere.start.json'
      loadJSONFixtures 'atmosphere.stop.json'
      loadJSONFixtures 'atmosphere.update.json'

    describe 'onMissionUpdate', ->
      beforeEach ->
        spyOn(@liveMapController, 'onMissionUpdate').and.callThrough()
        spyOn(@liveMapController, 'updateVehicle').and.callThrough()

      it 'should handle start frames', ->
        fakeMissionStart = getJSONFixture('atmosphere.start.json').data
        vehicleKey = @liveMapController.vehicleKey fakeMissionStart.missionId

        expect(@scope.vehicleMarkers[vehicleKey]).toBeUndefined()

        @liveMapController.onMissionUpdate fakeMissionStart

        expect(@liveMapController.updateVehicle).toHaveBeenCalled()
        expect(@scope.vehicleMarkers[vehicleKey].payload.id).toEqual fakeMissionStart.missionId

      describe 'update frame messages', ->
        beforeEach ->
          @fakeMissionUpdate = getJSONFixture('atmosphere.update.json').data

        it 'should create markers if it doesn\'t yet exist', ->
          vehicleKey = @liveMapController.vehicleKey @fakeMissionUpdate.missionId

          # make sure it doesn't exist yet
          expect(@scope.vehicleMarkers[vehicleKey]).toBeUndefined()

          @liveMapController.onMissionUpdate @fakeMissionUpdate

          # should be defined by now
          expect(@scope.vehicleMarkers[vehicleKey].payload.id).toEqual @fakeMissionUpdate.missionId

        it 'should update markers', ->
          fakeMissionStart = getJSONFixture('atmosphere.start.json').data
          vehicleKey = @liveMapController.vehicleKey fakeMissionStart.missionId

          expect(@fakeMissionUpdate.missionId).toEqual fakeMissionStart.missionId
          expect(@scope.vehicleMarkers[vehicleKey]).toBeUndefined()

          # Create new marker
          @liveMapController.onMissionUpdate fakeMissionStart
          expect(@scope.vehicleMarkers[vehicleKey].payload.id).toEqual fakeMissionStart.missionId

          lat = @scope.vehicleMarkers[vehicleKey].lat
          lng = @scope.vehicleMarkers[vehicleKey].lng

          # Update the marker
          @liveMapController.onMissionUpdate @fakeMissionUpdate
          expect(@scope.vehicleMarkers[vehicleKey].lat).not.toEqual lat
          expect(@scope.vehicleMarkers[vehicleKey].lng).not.toEqual lng

        it 'should zoom to the current user vehicle', ->
          spyOn(@liveMapController, 'zoomToVehicle')

          @scope.$apply()
          @httpBackend.flush()

          me = @liveMapController.authService.getUser()
          fakeMissionStart = getJSONFixture('atmosphere.start.json').data
          vehicleKey = @liveMapController.vehicleKey fakeMissionStart.missionId

          @liveMapController.onMissionUpdate fakeMissionStart

          expect(@scope.vehicleMarkers[vehicleKey]).not.toBeUndefined()
          expect(@liveMapController.zoomToVehicle).toHaveBeenCalled()

    describe 'onMissionDelete', ->
      it 'should remove vehicle marker', ->
        fakeMissionStop = getJSONFixture('atmosphere.stop.json').data
        fakeMissionStart = getJSONFixture('atmosphere.start.json').data
        vehicleKey = @liveMapController.vehicleKey fakeMissionStart.missionId

        expect(fakeMissionStop.missionId).toEqual fakeMissionStart.missionId
        expect(@scope.vehicleMarkers[vehicleKey]).toBeUndefined()

        @liveMapController.onMissionUpdate fakeMissionStart
        expect(@scope.vehicleMarkers[vehicleKey]).not.toBeUndefined()

        @liveMapController.onMissionDelete fakeMissionStop
        expect(@scope.vehicleMarkers[vehicleKey]).toBeUndefined()

    describe 'updateVehicleMessage', ->
      it 'should update marker popup', ->
        loadJSONFixtures 'atmosphere.mystery.json'

        spyOn(@liveMapController, 'updateMarkerPopup')
        @liveMapController.updateVehicleMessage getJSONFixture('atmosphere.mystery.json').data
        expect(@liveMapController.updateMarkerPopup).toHaveBeenCalled()

    describe 'onAttitude', ->
      it 'should update marker angle', ->
        loadJSONFixtures 'atmosphere.start.json'
        loadJSONFixtures 'atmosphere.att.json'
        fakeMissionStart = getJSONFixture('atmosphere.start.json').data
        fakeAttitude = getJSONFixture('atmosphere.att.json').data
        vehicleKey = @liveMapController.vehicleKey fakeMissionStart.missionId

        @liveMapController.onMissionUpdate fakeMissionStart
        expect(@scope.vehicleMarkers[vehicleKey]).not.toBeUndefined()

        @liveMapController.onAttitude fakeAttitude
        expect(@scope.vehicleMarkers[vehicleKey].iconAngle).toEqual fakeAttitude.payload.yaw
