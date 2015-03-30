(function() {
  var path;

  path = require('path');

  module.exports = function(grunt) {
    var appConfig;
    require('load-grunt-tasks')(grunt);
    require('time-grunt')(grunt);
    appConfig = {
      app: require('./bower.json').appPath || 'app',
      dist: 'dist'
    };
    grunt.initConfig({
      settings: {
        distDirectory: 'dist',
        srcDirectory: 'src',
        tempDirectory: '.temp',
        testDirectory: 'test',
        testPort: 9001,
        devPort: 9099
      },
      sauceconnect: {
        options: {
          keepAlive: true,
          accessKey: process.env.SAUCE_ACCESS_KEY,
          username: process.env.SAUCE_USERNAME
        },
        test: {},
        dev: {}
      },
      bower: {
        install: {
          options: {
            verbose: true,
            cleanTargetDir: true,
            copy: true,
            layout: function(type, component) {
              return path.join(type);
            },
            targetDir: 'bower_components'
          }
        },
        uninstall: {
          options: {
            cleanBowerDir: true,
            copy: false,
            install: false
          }
        }
      },
      clean: {
        working: ['<%= settings.tempDirectory %>', '<%= settings.distDirectory %>'],
        jslove: ['**/*.coffee', '!**/.temp/**', '!**/bower_components/**', '!**/node_modules/**']
      },
      coffee: {
        app: {
          files: [
            {
              cwd: '<%= settings.tempDirectory %>',
              src: '**/*.coffee',
              dest: '<%= settings.tempDirectory %>',
              expand: true,
              ext: '.js'
            }
          ],
          options: {
            sourceMap: true
          }
        },
        jslove: {
          files: [
            {
              cwd: '',
              src: '<%= clean.jslove %>',
              dest: '',
              expand: true,
              ext: '.js'
            }
          ]
        }
      },
      coffeelint: {
        app: {
          files: [
            {
              cwd: '',
              src: ['src/**/*.coffee', '!src/scripts/libs/**']
            }
          ],
          options: {
            indentation: {
              value: 2
            },
            max_line_length: {
              level: 'ignore'
            },
            no_tabs: {
              level: 'ignore'
            }
          }
        }
      },
      connect: {
        options: {
          port: '<%= settings.devPort %>',
          base: '<%= settings.distDirectory %>',
          hostname: 'localhost',
          livereload: 35729,
          middleware: require('./middleware')
        },
        app: {
          options: {
            open: true
          }
        },
        test: {
          options: {
            port: 9001
          }
        }
      },
      copy: {
        app: {
          files: [
            {
              cwd: '<%= settings.srcDirectory %>',
              src: '**',
              dest: '<%= settings.tempDirectory %>',
              expand: true
            }, {
              cwd: 'bower_components',
              src: '**',
              dest: '<%= settings.tempDirectory %>',
              expand: true
            }, {
              cwd: 'WEB-INF',
              src: 'app.yaml',
              dest: '<%= settings.tempDirectory %>/',
              expand: true
            }
          ]
        },
        dev: {
          cwd: '<%= settings.tempDirectory %>',
          src: '**',
          dest: '<%= settings.distDirectory %>',
          expand: true
        },
        prod: {
          files: [
            {
              cwd: '<%= settings.tempDirectory %>',
              src: ['**/*.{eot,svg,ttf,woff}', '**/*.{gif,jpeg,jpg,png,svg,webp}', 'index.html', 'scripts/ie.min.*.js', 'scripts/scripts.min.*.js', 'styles/styles.min.*.css'],
              dest: '<%= settings.distDirectory %>',
              expand: true
            }
          ]
        }
      },
      hash: {
        images: '.temp/**/*.{gif,jpeg,jpg,png,svg,webp}',
        scripts: {
          cwd: '.temp/scripts',
          src: ['ie.min.js', 'scripts.min.js'],
          expand: true
        },
        styles: '.temp/styles/styles.min.css'
      },
      imagemin: {
        images: {
          files: [
            {
              cwd: '<%= settings.tempDirectory %>',
              src: '**/*.{gif,jpeg,jpg,png}',
              dest: '<%= settings.tempDirectory %>',
              expand: true
            }
          ],
          options: {
            optimizationLevel: 7
          }
        }
      },
      karma: {
        unit: {
          options: {
            browsers: ['PhantomJS'],
            captureTimeout: 5000,
            colors: true,
            frameworks: ['jasmine'],
            keepalive: false,
            logLevel: 'INFO',
            port: 9876,
            reporters: ['dots', 'progress'],
            preprocessors: {
              '**/*.coffee': 'coffee'
            },
            files: [
              {
                pattern: 'dist/scripts/libs/angular.min.js',
                watched: false,
                served: true,
                included: true
              }, {
                pattern: 'dist/scripts/libs/angular*.min.js',
                watched: false,
                served: true,
                included: true
              }, {
                pattern: 'test/fixtures/*.json',
                watched: false,
                served: true,
                included: false
              }, {
                pattern: 'bower_components/scripts/libs/angular-mocks.js',
                watched: false,
                served: true,
                included: true
              }, {
                pattern: 'dist/scripts/libs/mapbox.js',
                watched: false,
                served: true,
                included: true
              }, {
                pattern: 'dist/scripts/libs/jquery.js',
                watched: false,
                served: true,
                included: true
              }, {
                pattern: 'bower_components/scripts/libs/jasmine-jquery.js',
                watched: false,
                served: true,
                included: true
              }, {
                pattern: 'dist/**/*.js',
                watched: false,
                served: true,
                included: true
              }, {
                pattern: 'test/units/**/*.coffee',
                watched: true,
                served: true,
                included: true
              }
            ],
            runnerPort: 9100,
            singleRun: !grunt.option('watch')
          }
        }
      },
      protractor_webdriver: {
        test_e2e: {
          options: {
            path: './node_modules/protractor/bin/',
            command: 'webdriver-manager start'
          }
        }
      },
      protractor: {
        options: {
          keepAlive: true,
          noColor: false
        },
        dev: {
          configFile: 'protractor.conf.coffee'
        },
        test_e2e: {
          options: {
            configFile: 'protractor.saucelabs.conf.coffee'
          }
        }
      },
      less: {
        app: {
          files: {
            '.temp/styles/styles.css': '.temp/styles/styles.less'
          }
        }
      },
      minifyHtml: {
        prod: {
          src: '.temp/index.html',
          ext: '.html',
          expand: true
        }
      },
      ngTemplateCache: {
        views: {
          files: {
            '.temp/scripts/views.js': '.temp/**/*.html'
          },
          options: {
            trim: '<%= settings.tempDirectory %>'
          }
        }
      },
      prompt: {
        jslove: {
          options: {
            questions: [
              {
                config: 'coffee.jslove.compile',
                type: 'input',
                message: 'Are you sure you wish to convert all CoffeeScript (.coffee) files to JavaScript (.js)?' + '\n' + 'This cannot be undone.'.red + ': (y/N)',
                "default": false,
                filter: function(input) {
                  var confirmed;
                  confirmed = /^y(es)?/i.test(input);
                  if (!confirmed) {
                    grunt.fatal('exiting jslove');
                  }
                  return confirmed;
                }
              }
            ]
          }
        }
      },
      requirejs: {
        scripts: {
          options: {
            baseUrl: '.temp/scripts',
            findNestedDependencies: true,
            logLevel: 0,
            mainConfigFile: '.temp/scripts/main.js',
            name: 'main',
            onBuildWrite: function(moduleName, path, contents) {
              var modulesToExclude, shouldExcludeModule;
              modulesToExclude = ['main'];
              shouldExcludeModule = modulesToExclude.indexOf(moduleName) >= 0;
              if (shouldExcludeModule) {
                return '';
              }
              return contents;
            },
            optimize: 'uglify2',
            out: '.temp/scripts/scripts.min.js',
            preserveLicenseComments: false,
            skipModuleInsertion: true,
            uglify: {
              no_mangle: false
            },
            useStrict: true,
            wrap: {
              start: '(function(){\'use strict\';',
              end: '}).call(this);'
            }
          }
        },
        styles: {
          options: {
            baseUrl: '.temp/styles/',
            cssIn: '.temp/styles/styles.css',
            logLevel: 0,
            optimizeCss: 'standard',
            out: '.temp/styles/styles.min.css'
          }
        }
      },
      shimmer: {
        dev: {
          cwd: '.temp/scripts',
          src: ['**/*.{coffee,js}', '!libs/html5shiv-printshiv.{coffee,js}', '!libs/json3.min.{coffee,js}', '!libs/require.{coffee,js}', '!libs/jasmine-jquery.js'],
          order: [
            'libs/spin.js', 'libs/ladda.js', 'custom/atmosphere.js', 'libs/jquery.js', 'libs/jquery.flot.js', 'libs/jquery.flot.time.js', 'libs/angular-file-upload-shim.min.js', 'libs/angular.min.js', 'libs/mapbox.js', {
              'NGAPP': {
                'ngProgressLite': 'libs/ngprogress-lite.js',
                'ngAnimate': 'libs/angular-animate.min.js',
                'ngRoute': 'libs/angular-route.min.js',
                'leaflet-directive': 'custom/angular-leaflet-directive.js',
                'ngAtmosphere': 'custom/angular-atmosphere.js',
                'angulartics': 'libs/angulartics.min.js',
                'angulartics.google.analytics': 'libs/angulartics-ga.min.js',
                'ui.bootstrap': 'libs/ui-bootstrap-tpls-0.11.0.min.js',
                'angular-flot': 'libs/angular-flot.js',
                'ngSocial': 'libs/angular-social.js',
                'angularFileUpload': 'libs/angular-file-upload.min.js',
                'infinite-scroll': 'libs/ng-infinite-scroll.js',
                'ngLaddaBootstrap': 'libs/ng-ladda-bootstrap.js',
                'highcharts-ng': 'libs/highcharts-ng.js'
              }
            }
          ],
          require: 'NGBOOTSTRAP'
        },
        prod: {
          cwd: '<%= shimmer.dev.cwd %>',
          src: ['**/*.{coffee,js}', '!libs/angular.{coffee,js}', '!libs/angular-animate.{coffee,js}', '!libs/angular-mocks.{coffee,js}', '!libs/angular-route.{coffee,js}', '!libs/html5shiv-printshiv.{coffee,js}', '!libs/json3.min.{coffee,js}', '!libs/require.{coffee,js}', '!libs/jasmine-jquery.js'],
          order: [
            'libs/spin.js', 'libs/ladda.js', 'custom/atmosphere.js', 'libs/jquery.js', 'libs/jquery.flot.js', 'libs/jquery.flot.time.js', 'libs/angular-file-upload-shim.min.js', 'libs/angular.min.js', 'libs/mapbox.js', {
              'NGAPP': {
                'ngProgressLite': 'libs/ngprogress-lite.js',
                'ngAnimate': 'libs/angular-animate.min.js',
                'ngRoute': 'libs/angular-route.min.js',
                'leaflet-directive': 'custom/angular-leaflet-directive.js',
                'ngAtmosphere': 'custom/angular-atmosphere.js',
                'angulartics': 'libs/angulartics.min.js',
                'angulartics.google.analytics': 'libs/angulartics-ga.min.js',
                'ui.bootstrap': 'libs/ui-bootstrap-tpls-0.11.0.min.js',
                'angular-flot': 'libs/angular-flot.js',
                'ngSocial': 'libs/angular-social.js',
                'angularFileUpload': 'libs/angular-file-upload.min.js',
                'infinite-scroll': 'libs/ng-infinite-scroll.js',
                'ngLaddaBootstrap': 'libs/ng-ladda-bootstrap.js',
                'highcharts-ng': 'libs/highcharts-ng.js'
              }
            }
          ],
          require: '<%= shimmer.dev.require %>'
        }
      },
      template: {
        indexDev: {
          files: {
            '.temp/index.html': '.temp/index.html'
          }
        },
        index: {
          files: '<%= template.indexDev.files %>',
          environment: 'prod'
        }
      },
      uglify: {
        scripts: {
          files: {
            '.temp/scripts/ie.min.js': ['.temp/scripts/libs/json3.js', '.temp/scripts/libs/html5shiv-printshiv.js']
          }
        }
      },
      watch: {
        basic: {
          files: ['src/fonts/**', 'src/images/**', 'src/scripts/**/*.js', 'src/styles/**/*.css', 'src/**/*.html'],
          tasks: ['coffeelint', 'copy:app', 'copy:dev', 'karma'],
          options: {
            livereload: true,
            nospawn: true
          }
        },
        coffee: {
          files: 'src/scripts/**/*.coffee',
          tasks: ['clean:working', 'coffeelint', 'copy:app', 'shimmer:dev', 'coffee:app', 'copy:dev', 'karma'],
          options: {
            livereload: true,
            nospawn: true
          }
        },
        less: {
          files: 'src/styles/**/*.less',
          tasks: ['copy:app', 'less', 'copy:dev'],
          options: {
            livereload: true,
            nospawn: true
          }
        },
        html: {
          files: 'src/views/**/*.html',
          tasks: ['copy:app', 'ngTemplateCache', 'shimmer:dev', 'template:indexDev', 'copy:dev']
        },
        spaHtml: {
          files: 'src/index.html',
          tasks: ['copy:app', 'template:indexDev', 'copy:dev', 'karma'],
          options: {
            livereload: true,
            nospawn: true
          }
        },
        test: {
          files: 'test/**/*.*',
          tasks: ['karma']
        },
        none: {
          files: 'none',
          options: {
            livereload: true
          }
        }
      }
    });
    grunt.event.on('watch', function(action, filepath, key) {
      var basename, coffeeConfig, coffeeLintConfig, copyDevConfig, dirname, ext, file;
      file = filepath.substr(4);
      dirname = path.dirname(file);
      ext = path.extname(file);
      basename = path.basename(file, ext);
      grunt.config(['copy', 'app'], {
        cwd: 'src/',
        src: file,
        dest: '.temp/',
        expand: true
      });
      copyDevConfig = grunt.config(['copy', 'dev']);
      copyDevConfig.src = file;
      if (key === 'coffee') {
        grunt.config(['clean', 'working'], [path.join('.temp', dirname, "" + basename + ".{coffee,js,js.map}")]);
        copyDevConfig.src = [path.join(dirname, "" + basename + ".{coffee,js,js.map}"), 'scripts/main.{coffee,js,js.map}'];
        coffeeConfig = grunt.config(['coffee', 'app', 'files']);
        coffeeConfig.src = file;
        coffeeLintConfig = grunt.config(['coffeelint', 'app', 'files']);
        coffeeLintConfig = filepath;
        grunt.config(['coffee', 'app', 'files'], coffeeConfig);
        grunt.config(['coffeelint', 'app', 'files'], coffeeLintConfig);
      }
      if (key === 'less') {
        copyDevConfig.src = [path.join(dirname, "" + basename + ".{less,css}"), path.join(dirname, 'styles.css')];
      }
      return grunt.config(['copy', 'dev'], copyDevConfig);
    });
    grunt.registerTask('build', ['clean:working', 'coffeelint', 'copy:app', 'ngTemplateCache', 'shimmer:dev', 'coffee:app', 'less', 'template:indexDev', 'copy:dev']);
    grunt.registerTask('default', ['build', 'connect', 'watch']);
    grunt.registerTask('dev', ['default']);
    grunt.registerTask('prod', ['clean:working', 'coffeelint', 'copy:app', 'ngTemplateCache', 'shimmer:prod', 'coffee:app', 'imagemin', 'hash:images', 'less', 'requirejs', 'uglify', 'hash:scripts', 'hash:styles', 'template:index', 'minifyHtml', 'copy:prod']);
    grunt.registerTask('server', ['connect', 'watch:none']);
    grunt.registerTask('test', ['build', 'karma', 'integration-tests:dev']);
    grunt.registerTask('jslove', ['prompt:jslove', 'coffee:jslove', 'clean:jslove']);
    grunt.registerTask('integration-tests', ['build', 'connect:test', 'sauceconnect:test', 'protractor:test_e2e']);
    return grunt.registerTask('integration-tests:dev', ['connect:test', 'protractor_webdriver', 'protractor:dev']);
  };

}).call(this);
