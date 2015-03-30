(function() {
  describe('twitterfy', function() {
    beforeEach(module('app'));
    return it('username should be prepended with the @ sign', inject([
      'twitterfyFilter', function(twitterfy) {
        var twitterHandle, twitterfied;
        twitterHandle = 'CaryLandholt';
        twitterfied = twitterfy(twitterHandle);
        expect(twitterfied).toEqual("@" + twitterHandle);
        return expect(twitterfied).not.toEqual(twitterHandle);
      }
    ]));
  });

}).call(this);
