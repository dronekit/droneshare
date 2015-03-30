(function() {
  describe('header', function() {
    beforeEach(function() {
      return browser.get('index.html');
    });
    return describe('menu', function() {
      return it('should consist of 3 menu items', function() {
        var list;
        list = element.all(findBy.css('#navigation a'));
        return expect(list.count()).toBe(3);
      });
    });
  });

}).call(this);
