'use strict';

// From https://github.com/bertramdev/angular-atmosphere/blob/master/app/scripts/services/angular-atmosphere.js

function NoAtmospherePluginError(message) {
  this.prototype.name = 'NoAtmospherePluginError';
  this.message = (message || 'The Atmosphere plugin for jQuery was not found');
}

NoAtmospherePluginError.prototype = new Error();

angular.module('ngAtmosphere', [])
  .factory('atmosphere', [function () {

    if (!window.atmosphere) {
      throw new NoAtmospherePluginError();
    }

    var debug = false;
    var listeners = {};
    var listenerIndex = {};

    var connection;

    function handleResponse(response) {
      var data = response.responseBody;
      if (typeof data === 'string'){
        data = angular.fromJson(data);
      }
      if (debug){
        console.log('ngAtmosphere DEBUG: received response from server', data.type, JSON.stringify(data));
      }

      var callByKey = function (key) {
        if (listeners.hasOwnProperty(key))
          angular.forEach(listeners[key], function (listener) {
            listener.fn.call(this, data.data);
          });
        };

      callByKey(data.type);
      callByKey(null);
    }

    // Public API here
    return {
      init: function (requestObj) {
        if (!connection) {
          var request = requestObj;
          request.onMessage = handleResponse;

          connection = window.atmosphere.subscribe(request);
          if (debug) {
            console.log('ngAtmosphere DEBUG: connection made to: ' + connection.getUrl());
          }
        }
      },
      close: function () {
        if(connection){
          if (debug) {
            console.log('ngAtmosphere DEBUG: unsubscribing to ' + connection.getUrl());
          }
          window.atmosphere.unsubscribeUrl(connection.getUrl());
          connection = null;
        }
      },

      // type is either a string to match or null to receive all msgs
      on: function (type, callbackFn) {

        var id = Math.random();

        if (!listeners.hasOwnProperty(type)) {
          listeners[type] = [];
        }
        listenerIndex[id] = type;
        listeners[type].push({id: id, fn: callbackFn});

        if (debug) {
          console.log('ngAtmosphere DEBUG: added callback to ' + type + ' and given the id of ' + id);
        }

        return id;
      },
      off: function (id) {
        var type = listenerIndex[id];
        var typeListeners = listeners[type];
        var removed = false;

        for (var i = 0; i < typeListeners.length; i++) {
          if (typeListeners[i].id === id) {
            typeListeners.splice(i, 1);
            delete listenerIndex[id];

            removed = true;
            break;
          }
        }
        if (debug) {
          console.log('ngAtmosphere DEBUG: removed callback from ' + type + ' with the id of: ' + id);
        }

        return removed;
      },
      emit: function (type, data) {
        if (debug) {
          console.log('ngAtmosphere DEBUG: sending data with type: ' + type, connection, data);
        }
        connection.push(angular.toJson({type: type, data: data}));
      },
      debug: function(enable){
        debug = enable;
      }
    };
  }]);
