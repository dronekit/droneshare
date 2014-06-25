describe "mapController", ->
  beforeEach module 'app'
  beforeEach inject ($rootScope, $controller) ->
    @scope = $rootScope.$new()
    @controller = $controller('mapController', { '$scope': @scope })

  it 'should initMap and set defaults', ->
    expect(@scope.defaults.scrollWheelZoom).toBeTruthy()
    expect(@scope.defaults.zoom).toEqual 10
    expect(@scope.defaults.minZoom).toEqual 2

  it 'should initMap and set mapbox tiles', ->
    expect(@scope.tiles.url).toMatch /mapbox/
