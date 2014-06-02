
angular.module('app').filter 'toMapIcon', () ->
  (vehicleTypeStr) ->
    if vehicleTypeStr == "fixed-wing"
      "airport"
    else
      "heliport"
