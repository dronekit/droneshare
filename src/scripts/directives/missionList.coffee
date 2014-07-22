angular.module('app').directive 'missionList', -> return {
  restrict: 'A'
  templateUrl: '/views/directives/mission-list.html'
  controller: ['$scope', ($scope) ->
    $scope.busy = true
  ]
  compile: (element, attributes) ->
    pre: ($scope, element, attributes, controller) ->
      $scope.fetchParams =
        order_by: "createdAt"
        order_dir: "desc"
        page_size: 12
        page_offset: 0

      $scope.nextPage = ->
        $scope.busy = true
        offset = $scope.fetchParams.page_offset
        offset = 1 if $scope.fetchParams.page_offset == 0
        $scope.fetchParams.page_offset = $scope.fetchParams.page_size + offset
        $scope.fetchMissions($scope.fetchParams).then (records) ->
          $scope.busy = false
          $scope.records = $scope.records.concat records

    post: ($scope, element, attributes, controller) ->
      $scope.busy = false
}
