(function() {
  var Directive;

  Directive = (function() {
    function Directive($log) {
      var link;
      link = function(scope, element, attrs, controller) {
        return controller.addTab(scope, attrs.tabId);
      };
      return {
        link: link,
        locals: {
          transcluded: '@'
        },
        replace: true,
        require: '^appTabs',
        restrict: 'E',
        scope: {
          caption: '@',
          selected: '@'
        },
        templateUrl: '/views/directives/tab.html',
        transclude: true
      };
    }

    return Directive;

  })();

  angular.module('app').directive('appTab', ['$log', Directive]);

}).call(this);
