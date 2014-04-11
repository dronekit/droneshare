class NavbarController
	constructor: (@$scope, @$location) ->
		@$scope.navClass = (page) =>
			currentRoute = @$location.path().substring(1) || '/'
			return if (page == currentRoute) then 'active' else ''

angular.module('app').controller 'navCtrl', ['$scope', '$location', NavbarController]
