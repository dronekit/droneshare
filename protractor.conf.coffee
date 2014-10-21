exports.config =

  allScriptsTimeout: 99999

  #// Capabilities to be passed to the webdriver instance.
  multiCapabilities: [{
    'browserName': 'firefox'
  }, {
    'browserName': 'chrome'
  }, {
    'browserName': 'safari'
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
    defaultTimeoutInterval: 30000
    isVerbose : true
    includeStackTrace : true
