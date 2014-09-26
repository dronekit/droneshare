angular.module('app').directive 'missionPlot', ['$log', '$window', ($log, $window) -> return {
  restrict: 'A'
  controllerAs: 'controller'
  templateUrl: '/views/directives/mission-plot.html'
  scope:
    'series': '='
  controller: ['$scope', (@scope) ->
    @getPlotWidthHeight = =>
      navHeight = ($ 'header[header-nav]').height()
      infoHeight = ($ '.plot-info').height()
      plotHeight = ($ window).height() - navHeight - infoHeight - 200
      plotWidth = ($ '.highcharts-plot').width()
      [plotHeight, plotWidth]

    size = @getPlotWidthHeight()

    @resizeChart = =>
      size = @getPlotWidthHeight()
      plotHeight = size[0]
      plotWidth = size[1]
      @scope.$apply =>
        @scope.chartConfig.size.width = plotWidth
        @scope.chartConfig.size.height = plotHeight

    @scope.chartConfig =
      options:
        chart:
          type: 'line'
          zoomType: 'x'
      title:
        text: 'Param Plot'
      series: ({name: option.label, data: option.data} for option in @scope.series)
      size:
        height: size[0]
        width: size[1]

    return @
  ]
  link: ($scope, element, attributes, controller) ->
    ($ window).resize controller.resizeChart
    #controller.resizeChart(false)
}]

