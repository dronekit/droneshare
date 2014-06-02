class Duration
  constructor: (@$log, @$filter) ->
    return (seconds) ->
      sec_num = parseInt(seconds, 10)
      hours   = Math.floor(sec_num / 3600)
      minutes = Math.floor((sec_num - (hours * 3600)) / 60)
      seconds = sec_num - (hours * 3600) - (minutes * 60)

      hours   = "0" + hours if hours < 10
      minutes = "0" + minutes if minutes < 10
      seconds = "0" + seconds if seconds < 10

      hours + ':' + minutes + ':' + seconds

angular.module('app').filter 'duration', ['$log', '$filter', Duration]
