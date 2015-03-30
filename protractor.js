(function() {
  exports.config = {
    allScriptsTimeout: 99999,
    multiCapabilities: [
      {
        'browserName': 'firefox'
      }, {
        'browserName': 'chrome'
      }
    ],
    baseUrl: 'http://localhost:9001/',
    framework: 'jasmine',
    onPrepare: function() {
      return global.findBy = protractor.By;
    },
    specs: ['test/e2e/**/*.coffee'],
    jasmineNodeOpts: {
      showColors: true,
      defaultTimeoutInterval: 30000,
      isVerbose: true,
      includeStackTrace: true
    }
  };

}).call(this);

(function() {
  exports.config = {
    allScriptsTimeout: 99999,
    sauceUser: process.env.SAUCE_USERNAME,
    sauceKey: process.env.SAUCE_ACCESS_KEY,
    multiCapabilities: [
      {
        browserName: 'internet explorer',
        platform: 'Windows 7',
        version: '9'
      }, {
        browserName: 'internet explorer',
        platform: 'Windows 8',
        version: '10'
      }, {
        browserName: 'internet explorer',
        platform: 'Windows 8.1',
        version: '11'
      }, {
        browserName: 'chrome',
        platform: 'Windows 8.1',
        version: ''
      }, {
        browserName: 'firefox',
        platform: 'Windows 8.1',
        version: '33'
      }, {
        browserName: 'safari',
        platform: 'OS X 10.9',
        version: '7'
      }, {
        browserName: 'safari',
        platform: 'OS X 10.9',
        version: '7'
      }
    ],
    baseUrl: 'http://localhost:9001/',
    framework: 'jasmine',
    onPrepare: function() {
      return global.findBy = protractor.By;
    },
    specs: ['test/e2e/**/*.coffee'],
    jasmineNodeOpts: {
      showColors: true,
      defaultTimeoutInterval: 30000,
      isVerbose: true,
      includeStackTrace: true
    }
  };

}).call(this);
