class Capitalize
  constructor: (@$filter) ->
    return (words) ->
      (words.split(' ').map (word) -> word.charAt(0).toUpperCase() + word.slice(1)).join('')

angular.module('app').filter 'capitalize', ['$filter', Capitalize]
