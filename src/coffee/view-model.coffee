define 'viewmodel', ['jquery', 'knockout', 'lodash', 'moment', 'mapbox-gl', 'chartjs', 'randomcolor', 'knockout-paging'], ($, ko, _, moment, mapboxgl, Chart, randomColor) ->
  class ViewModel
    constructor: () ->
      @activitiesData = ko.observableArray()
      @activitiesData.extend
        paged:
          pageSize: 15
      @totalDistanceGroupedByMonth = ko.pureComputed => @_totalDistanceByMonth()
      @activitiesMonthYears = ko.pureComputed => @_activitiesMonthYears()

      @_loadData().then =>
        @_loadMap()
        @_loadDistanceByMonthBarChart()

    _loadMap: ->
      mapboxgl.accessToken = 'pk.eyJ1IjoiYnJlbm5hbm5lb2giLCJhIjoiY2lyMDRjaXZrMDJweWZwbWd5d3JrNmR0MSJ9.Cek0zIm8OfVVY2pnyiRqVw'
      map = new mapboxgl.Map
        container: 'map'
        style: 'mapbox://styles/mapbox/streets-v9'
        center: [103.7775, 1.3484]
        zoom: 12
      map.on 'load', =>
        data = @activitiesData()
        [0..4].forEach (index) ->
          item = data[index]
          map.addSource "route-#{item.id}",
            type: 'geojson'
            data:
              type: 'Feature'
              properties: {}
              geometry:
                type: 'LineString'
                coordinates: item.summary_coordinates
          map.addLayer
            id: "route-#{item.id}"
            type: 'line'
            source: "route-#{item.id}"
            layout:
              'line-join': 'round'
              'line-cap': 'round'
            paint:
              'line-color': item.line_color
              'line-width': 5

    _loadData: ->
      json = $.ajax 'js/activities.json'
      json.then (data) =>
        for item in data
          item.avatar_url = "https://github.com/#{item.athlete.username}.png?size=20"
          item.date = moment(item.start_date).format 'MMMM Do'
          item.time = moment(item.start_date_local).parseZone(item.timezone).format 'HH:mm:ss'
          distance = item.distance / 1000
          item.distance_kilometer = "#{distance.toFixed(1)} km"
          item.average_speed = @_formatSpeed(item.average_speed)
          item.max_speed = @_formatSpeed(item.max_speed)

        data = _.orderBy data, ['start_date', 'start_date_local'], ['desc', 'desc']
        @activitiesData _.filter data, (item) ->
          _.includes [1..5], moment(item.start_date_local).isoWeekday()

    _loadDistanceByMonthBarChart: ->
      backgroundColor = _.times _.size(@totalDistanceGroupedByMonth()), () -> randomColor()
      distanceData = _.values @totalDistanceGroupedByMonth()
      labels = @activitiesMonthYears()
      data =
        labels: labels
        datasets: [
          {
            label: 'Total'
            backgroundColor: backgroundColor
            data: distanceData
          }
        ]
      context = $('#distance-by-month')
      distanceByMonthChart = new Chart context,
        type: 'horizontalBar'
        data: data

    _activitiesMonthYears: ->
      monthYears = _.map @activitiesData(), (data) ->
        moment(data.start_date).format('MMMM YYYY')
      _.uniq monthYears

    _totalDistanceByMonth: ->
      totalDistanceByMonth = {}
      @activitiesData().forEach (item) =>
        itemMonthYear = moment(item.start_date).format 'MMMM YYYY'
        totalDistanceByMonth[itemMonthYear] ||= 0
        if _.includes(@activitiesMonthYears(), itemMonthYear)
          totalDistanceByMonth[itemMonthYear] += item.distance / 1000
      _.map totalDistanceByMonth, (item) -> item.toFixed(1)

    _formatSpeed: (speed) ->
      speed = speed * 3600 / 1000
      "#{speed.toFixed(1)} km/h"
