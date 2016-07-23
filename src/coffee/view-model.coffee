define 'viewModel', ['jquery', 'knockout', 'lodash', 'moment'], ($, ko, _, moment) ->
  class viewModel
    constructor: () ->
      @activitiesData = ko.observableArray()
      @_loadData()

    _loadData: ->
      json = $.ajax 'js/activities.json'
      json.done (data) =>
        for item in data
          distance = item.distance / 1000
          item.distance = "#{distance.toFixed(1)} km"
          average_speed = item.average_speed * 3600 / 1000
          item.average_speed = "#{average_speed.toFixed(1)} km/h"

        @activitiesData data
