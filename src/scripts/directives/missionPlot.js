(function() {
  angular.module('app').directive('missionPlot', [
    '$log', '$window', function($log, $window) {
      return {
        restrict: 'A',
        controllerAs: 'controller',
        templateUrl: '/views/directives/mission-plot.html',
        scope: {
          'series': '='
        },
        controller: [
          '$scope', function(scope) {
            var option, size;
            this.scope = scope;
            this.getPlotWidthHeight = (function(_this) {
              return function() {
                var infoHeight, navHeight, plotHeight, plotWidth;
                navHeight = ($('header[header-nav]')).height();
                infoHeight = ($('.plot-info')).height();
                plotHeight = ($(window)).height() - navHeight - infoHeight - 200;
                plotWidth = ($('.highcharts-plot')).width();
                return [plotHeight, plotWidth];
              };
            })(this);
            size = this.getPlotWidthHeight();
            this.resizeChart = (function(_this) {
              return function() {
                var plotHeight, plotWidth;
                size = _this.getPlotWidthHeight();
                plotHeight = size[0];
                plotWidth = size[1];
                return _this.scope.$apply(function() {
                  _this.scope.chartConfig.size.width = plotWidth;
                  return _this.scope.chartConfig.size.height = plotHeight;
                });
              };
            })(this);
            this.scope.chartConfig = {
              options: {
                chart: {
                  type: 'line',
                  zoomType: 'x'
                }
              },
              xAxis: {
                ordinal: false,
                type: 'datetime',
                tickInterval: 2 * 60 * 1000,
                labels: {
                  rotation: -45
                },
                dateTimeLabelFormats: {
                  day: '%H:%M',
                  hour: '%I %p',
                  minute: '%I:%M %p'
                }
              },
              title: {
                text: 'Param Plot'
              },
              series: (function() {
                var _i, _len, _ref, _results;
                _ref = this.scope.series;
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  option = _ref[_i];
                  _results.push({
                    name: option.label,
                    data: option.data
                  });
                }
                return _results;
              }).call(this),
              size: {
                height: size[0],
                width: size[1]
              }
            };
            return this;
          }
        ],
        link: function($scope, element, attributes, controller) {
          return ($(window)).resize(controller.resizeChart);
        }
      };
    }
  ]);

}).call(this);
