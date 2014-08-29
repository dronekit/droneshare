angular.module('app').directive 'missionList', -> return {
  restrict: 'A'
  controllerAs: 'controller'
  templateUrl: '/views/directives/mission-list.html'
  scope:
    'pageSize': '='
    'noInfiniteScroll': '='
    'preFetched': '='
    'records': '='
    'allowDurationFilter': '='
  controller: ['$scope', '$sce', 'missionService', 'authService', (@scope, @sce, @service, @authService) ->
    @currentUser = @authService.getUser()

    @scope.loaded = if @scope.preFetched then true else false
    @scope.missionScopeTitle = 'All'
    @scope.missionDataSet = 'all'
    @scope.vehicleType = ''
    @scope.dropDownIsOpen =
      field: false
      opt: false

    @fetchParams =
      order_by: 'createdAt'
      order_dir: 'desc'
      page_offset: 0
      page_size: 12

    @createFilterField = (title, field, units) ->
      filter =
        title: title
        field: field
        units: units

    @createFilterOpt = (title, opt) =>
      filter =
        title: @sce.trustAsHtml(title)
        opt: opt

    @filterFields = [
      @createFilterField('Max Groundspeed', 'field_maxGroundspeed', 'm/s')
      @createFilterField('Duration', 'field_flightDuration', 'min')
      @createFilterField('Max Airspeed', 'field_maxAirspeed', 'm/s')
      @createFilterField('Max Altitude', 'field_maxAlt', 'm')
      @createFilterField('Latitude', 'field_latitude', '')
      @createFilterField('Longitude', 'field_longitude', '')
    ]

    @filterOpts = [
      @createFilterOpt('&gt;', 'GT')
      @createFilterOpt('&gt;=', 'GE')
      @createFilterOpt('==', 'EQ')
      @createFilterOpt('&lt;', 'LT')
      @createFilterOpt('&lt;=', 'LE')
      @createFilterOpt('&lt;&gt;', 'NE')
    ]

    @scope.filters =
      field: @filterFields[0]
      opt: @filterOpts[0]
      input: ''

    @vehicleTypes = [
      "quadcopter"
      "tricopter"
      "coaxial"
      "hexarotor"
      "octorotor"
      "fixed-wing"
      "ground-rover"
      "submarine"
      "airship"
      "flapping-wing"
      "boat"
      "free-balloon"
      "antenna-tracker"
      "generic"
      "rocket"
      "helicopter"
    ]

    @allMissions = =>
      @scope.missionScopeTitle = "All"
      @service.getAllMissions().then @assignRecords

    @userMissions = (filterParams = false) =>
      @scope.missionScopeTitle = "My"
      @service.getUserMissions(@currentUser.login, filterParams).then @assignRecords

    @getVehicleTypeMissions = (vehicleType) =>
      @service.getVehicleTypeMissions(vehicleType).then @assignRecords

    @getDurationMissions = (duration, opt) =>
      duration *= 60 # data given in minutes API needs seconds
      @service.getDurationMissions(duration, opt).then @assignRecords

    @getMaxAltMissions = (maxAlt, opt) =>
      @service.getMaxAltMissions(maxAlt, opt).then @assignRecords

    @getMaxGroundSpeedMissions = (speed, opt) =>
      @service.getMaxGroundSpeedMissions(speed, opt).then @assignRecords

    @getMaxAirSpeedMissions = (speed, opt = 'GT') =>
      @service.getMaxAirSpeedMissions(speed, opt).then @assignRecords

    @getLatitudeMissions = (latitude, opt = 'GT') =>
      @service.getLatitudeMissions(latitude, opt).then @assignRecords

    @getLongitudeMissions = (longitude, opt = 'GT') =>
      @service.getLongitudeMissions(longitude, opt).then @assignRecords

    @setFetchParams = (fetchParams) =>
      anular.extend(@fetchParams, fetchParams)
      @fetchParams

    @sortCreatedAt = =>
      # figure out how to toggle sort by other fields

    @assignRecords = (records) =>
      @scope.records = records

    @appendRecords = (records) =>
      @scope.records.concat records

    @chooseDataSet = =>
      @allMissions() if @scope.missionDataSet == 'all'
      @userMissions() if @scope.missionDataSet == 'mine'

    @filterDataSet = (value, opt)=>
      if @scope.missionDataSet == 'all'
        switch @scope.filters.field.field
          when 'field_maxGroundspeed' then @getMaxGroundSpeedMissions(value, opt)
          when 'field_flightDuration' then @getDurationMissions(value, opt)
          when 'field_maxAirspeed' then @getMaxAirSpeedMissions(value, opt)
          when 'field_maxAlt' then @getMaxAltMissions(value, opt)
          when 'field_latitude' then @getLatitudeMissions(value, opt)
          when 'field_longitude' then @getLongitudeMissions(value, opt)
          else console.log("something is wrong")
      else if @scope.missionDataSet == 'mine'
        console.log 'user stuff'

    @setCreatedAt = (sort) =>
      fetchParams = @service.getFetchParams()
      fetchParams.order_dir = sort
      @service.fetchParams = fetchParams

    @nextPage = =>
      @scope.busy = true
      #offset = $scope.requestParams.page_offset
      #offset = 1 if $scope.requestParams.page_offset == 0
      #$scope.requestParams.page_offset = $scope.requestParams.page_size + offset
      #@fetchAppendRecords() # this is the new way of appending to current records
      #$scope.fetchMissions($scope.requestParams).then (records) ->
      #$scope.busy = false
      #$scope.records = $scope.records.concat records
      console.log 'nxtpge'

    return @
  ]
  link: ($scope, element, attributes, controller) ->
    $scope.busy = false

    $scope.$watch 'missionDataSet', (newValue, oldValue) =>
      unless newValue == oldValue
        controller.queryFilterHidden = if $scope.missionDataSet == 'mine' then true else false
        controller.chooseDataSet()

    $scope.tryFilterField = (index) =>
      $scope.dropDownIsOpen.field = false
      $scope.filters.field = controller.filterFields[index]

    $scope.tryFilterOp = (index) =>
      $scope.dropDownIsOpen.opt = false
      $scope.filters.opt = controller.filterOpts[index]

    $scope.tryFilterDataSet = =>
      controller.filterDataSet $scope.filters.input, $scope.filters.opt.opt

    $scope.checkIfNextPage = ->
      return false if $scope.noInfiniteScroll
      controller.nextPage()

    $scope.toggleCreatedAt = =>
      controller.createdAt = if controller.createdAt == 'asc' then 'desc' else 'asc'
      controller.setCreatedAt(newValue)
      controller.chooseDataSet()
}
