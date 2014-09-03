angular.module('app').directive 'missionList', -> return {
  restrict: 'A'
  controllerAs: 'controller'
  templateUrl: '/views/directives/mission-list.html'
  scope:
    'pageSize': '='
    'noInfiniteScroll': '='
    'preFetched': '='
    'records': '='
  controller: ['$scope', '$sce', 'missionService', 'authService', (@scope, @sce, @service, @authService) ->
    @currentUser = @authService.getUser()

    if @scope.preFetched
      @scope.busy = false
    else
      @scope.busy = true
      @allMissions().then (results) => @scope.busy = false

    @scope.filterInProgress = false
    @scope.filtersActive = false
    @scope.loaded = if @scope.preFetched then true else false
    @scope.missionScopeTitle = 'All'
    @scope.missionDataSet = 'all'
    @scope.vehicleType = ''
    @scope.dropDownIsOpen =
      field: false
      opt: false

    @getFetchParams = =>
      fetchParams =
        order_by: 'createdAt'
        order_dir: 'desc'
        page_offset: 0
        page_size: 12

    @setFetchParamsFilter = (value) =>
      @fetchParams = @getFetchParams()
      @fetchParams["#{@scope.filters.field.field}[#{@scope.filters.opt.opt}]"] = value
      @fetchParams

    @createFilterField = (title, field, units) ->
      filter =
        title: title
        field: field
        units: units

    @createFilterOpt = (title, opt, humanize) =>
      filter =
        title: @sce.trustAsHtml(title)
        opt: opt
        humanize: humanize

    @fetchParams = @getFetchParams()

    @filterFields = [
      @createFilterField('Max Groundspeed', 'field_maxGroundspeed', 'm/s')
      @createFilterField('Duration', 'field_flightDuration', 'min')
      @createFilterField('Max Airspeed', 'field_maxAirspeed', 'm/s')
      @createFilterField('Max Altitude', 'field_maxAlt', 'm')
      @createFilterField('Latitude', 'field_latitude', '')
      @createFilterField('Longitude', 'field_longitude', '')
    ]

    @filterOpts = [
      @createFilterOpt('&gt;', 'GT', 'greater than')
      @createFilterOpt('&gt;=', 'GE', 'greater or equal to')
      @createFilterOpt('==', 'EQ', 'equal to')
      @createFilterOpt('&lt;', 'LT', 'lower than')
      @createFilterOpt('&lt;=', 'LE', 'equal or lower than')
      @createFilterOpt('!=', 'NE', 'different than')
    ]

    @scope.filters =
      field: @filterFields[0]
      opt: @filterOpts[0]
      input: ''
      dataset: ''

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
      # reset fetchParams
      @fetchParams = @getFetchParams()
      @service.getAllMissions().then @assignRecords

    @userMissions = (filterParams = false) =>
      @scope.missionScopeTitle = "My"
      # reset fetchParams
      @fetchParams = @getFetchParams()
      # then add user login limitation
      @fetchParams['field_userName'] = @currentUser.login
      @service.getUserMissions(@currentUser.login, filterParams).then @assignRecords

    @getVehicleTypeMissions = (vehicleType) =>
      @service.getVehicleTypeMissions(vehicleType).then @assignRecords

    @getDurationMissions = (duration, opt) =>
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

    @sortCreatedAt = =>
      # figure out how to toggle sort by other fields

    @assignRecords = (records) =>
      @scope.records = records

    @appendRecords = (records) =>
      @scope.records = @scope.records.concat records

    @chooseDataSet = =>
      return @allMissions() if @scope.missionDataSet == 'all'
      return @userMissions() if @scope.missionDataSet == 'mine'

    @filterDataSet = (value, opt)=>
      @scope.filterInProgress = true
      # if trying to get duration input from user is in minutes
      # API expects seconds, need to convert
      value *= 60 if @scope.filters.field.field == 'field_flightDuration'
      # set the fetchParams so that we can use them later
      @setFetchParamsFilter value

      if @scope.missionDataSet == 'all'
        switch @scope.filters.field.field
          when 'field_maxGroundspeed' then @getMaxGroundSpeedMissions(value, opt).then @filterClear
          when 'field_flightDuration' then @getDurationMissions(value, opt).then @filterClear
          when 'field_maxAirspeed' then @getMaxAirSpeedMissions(value, opt).then @filterClear
          when 'field_maxAlt' then @getMaxAltMissions(value, opt).then @filterClear
          when 'field_latitude' then @getLatitudeMissions(value, opt).then @filterClear
          when 'field_longitude' then @getLongitudeMissions(value, opt).then @filterClear
          else console.log("something is wrong")
      else if @scope.missionDataSet == 'mine'
        # since we know set the fetchParams before choosing
        # which dataSet to work on, we can just tell the service
        # to poll the user missions with this filters applied
        @userMissions(@fetchParams).then @filterClear

    @filterClear = =>
      @scope.filterInProgress = false

    @setCreatedAt = (sort) =>
      fetchParams = @service.getFetchParams()
      fetchParams.order_dir = sort
      @service.fetchParams = fetchParams

    @nextPage = =>
      return false if @scope.busy
      @scope.busy = true

      offset = @fetchParams.page_offset
      offset = 1 if @fetchParams.page_offset == 0
      @fetchParams.page_offset = @fetchParams.page_size + offset

      @service.getMissions(@fetchParams).then (records) =>
        @scope.busy = false
        @appendRecords(records)

    return @
  ]
  link: ($scope, element, attributes, controller) ->
    $scope.$watch 'missionDataSet', (newValue, oldValue) =>
      unless newValue == oldValue
        #controller.queryFilterHidden = if $scope.missionDataSet == 'mine' then true else false
        controller.chooseDataSet()

    $scope.tryFilterField = (index) =>
      $scope.dropDownIsOpen.field = false
      $scope.filters.field = controller.filterFields[index]

    $scope.tryFilterOp = (index) =>
      $scope.dropDownIsOpen.opt = false
      $scope.filters.opt = controller.filterOpts[index]

    $scope.tryFilterDataSet = =>
      $scope.filtersActive = true
      controller.filterDataSet $scope.filters.input, $scope.filters.opt.opt
      # humanized filter query
      $scope.filters.dataset = "#{$scope.filters.field.title} is #{$scope.filters.opt.humanize} #{$scope.filters.input}"

    $scope.checkIfNextPage = ->
      return false if $scope.noInfiniteScroll
      controller.nextPage()

    $scope.toggleCreatedAt = =>
      controller.createdAt = if controller.createdAt == 'asc' then 'desc' else 'asc'
      controller.setCreatedAt(newValue)
      controller.chooseDataSet()

    ($ '.form-control-input-clear').bind 'click', (event) =>
      console.log 'click clear ', $scope.filtersActive
      if $scope.filtersActive
        $scope.filtersActive = false
        $scope.filterInProgress = true
        $scope.filters.input = ''
        $scope.filters.dataset = ''
        controller.chooseDataSet().then controller.filterClear
}
