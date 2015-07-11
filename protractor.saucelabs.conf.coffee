exports.config =
  allScriptsTimeout: 99999

  sauceUser: process.env.SAUCE_USERNAME,
  sauceKey: process.env.SAUCE_ACCESS_KEY,

  multiCapabilities: [{
    browserName: 'internet explorer'
    platform : 'Windows 7'
    version : '9'
  },{
    browserName: 'internet explorer'
    platform : 'Windows 8'
    version : '10'
  }, {
    browserName: 'internet explorer'
    platform : 'Windows 8.1'
    version : '11'
  }, {
    browserName: 'chrome'
    platform : 'Windows 8.1'
    version : ''
  }, {
    browserName: 'firefox'
    platform : 'Windows 8.1'
    version : '33'
  }, {
    browserName: 'safari'
    platform : 'OS X 10.9'
    version : '7'
  }, {
    browserName: 'safari'
    platform : 'OS X 10.9'
    version : '7'
  }]
  baseUrl: 'http://localhost:9001/'

  framework: 'jasmine'

  onPrepare: ->
    global.findBy = protractor.By

  #// Spec patterns are relative to the current working directly when
  #// protractor is called.
  specs: ['test/e2e/**/*.coffee']

  #// Options to be passed to Jasmine-node.
  jasmineNodeOpts:
    showColors: true
    defaultTimeoutInterval: 360000
    isVerbose : true
    includeStackTrace : true
