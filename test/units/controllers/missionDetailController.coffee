describe "missionDetailController", ->
  beforeEach module 'app'
  beforeEach inject ($rootScope, $controller, _$httpBackend_) ->
    loadJSONFixtures 'user.json'
    loadJSONFixtures 'mission.json'
    loadJSONFixtures 'messages.geo.json'

    @scope = $rootScope.$new()
    @user = getJSONFixture 'user.json'
    @mission = getJSONFixture 'mission.json'
    @geojson = getJSONFixture 'messages.geo.json'

    routeParamsStub = jasmine.createSpy('routeParamsStub')
    routeParamsStub.id = 218

    @userDetailController = $controller('missionDetailController', { '$scope': @scope, '$routeParams': routeParamsStub })
    @urlBase = 'https://api.droneshare.com/api/v1'
    @httpBackend = _$httpBackend_
    @httpBackend.whenGET("#{@urlBase}/auth/user").respond 200, @user
    @httpBackend.whenGET("#{@urlBase}/mission/#{routeParamsStub.id}").respond 200, @mission
    @httpBackend.whenGET("#{@urlBase}/mission/#{routeParamsStub.id}/messages.geo.json").respond 200, @geojson

  it 'gets mission record by params', ->
    expect(@scope.record).toBeUndefined()
    @scope.$apply()
    @httpBackend.flush()
    expect(@scope.record).not.toBeUndefined()

  describe 'get_geojson', ->
    it 'gets geojson data at init', ->
      expect(@scope.geojson).toEqual {}
      @scope.$apply()
      @httpBackend.flush()
      expect(@scope.geojson).not.toEqual {}

    it 'should set bounds', ->
      expect(@scope.bounds).toEqual {}
      @scope.$apply()
      @httpBackend.flush()

      expect(@scope.bounds).not.toEqual {}
      expect(@scope.bounds.southWest.lng).toEqual @geojson.bbox[0]
      expect(@scope.bounds.southWest.lat).toEqual @geojson.bbox[1]
      expect(@scope.bounds.northEast.lng).toEqual @geojson.bbox[3]
      expect(@scope.bounds.northEast.lat).toEqual @geojson.bbox[4]

  describe 'handle_fetch_response', ->
    it 'gets formats date to present to users', ->
      @scope.$apply()
      @httpBackend.flush()
      createdOn = new Date(@mission.createdOn)
      expect(@scope.record.dateString).toEqual "#{createdOn.toDateString()} - #{createdOn.toLocaleTimeString()}"

    it 'prepares data for social sharing', ->
      @scope.$apply()
      @httpBackend.flush()
      expect(@scope.$parent.ogImage).toEqual @mission.mapThumbnailURL
      expect(@scope.$parent.ogDescription).toEqual "#{@mission.userName} flew their drone in #{@mission.summaryText} for #{Math.round(@mission.flightDuration / 60)} minutes."
      expect(@scope.$parent.ogTitle).toEqual "#{@mission.userName}'s mission"
