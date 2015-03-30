(function() {
  describe("mapController", function() {
    beforeEach(module('app'));
    beforeEach(inject(function($rootScope, $controller) {
      this.scope = $rootScope.$new();
      return this.controller = $controller('mapController', {
        '$scope': this.scope
      });
    }));
    it('should initMap and set defaults', function() {
      expect(this.scope.defaults.scrollWheelZoom).toBeTruthy();
      expect(this.scope.defaults.zoom).toEqual(10);
      return expect(this.scope.defaults.minZoom).toEqual(2);
    });
    return it('should initMap and set mapbox layers', function() {
      return expect(this.scope.layers.baselayers.threedr_satview.url).toMatch(/mapbox/);
    });
  });

}).call(this);
