define 'viewmodel', ['jquery', 'knockout', 'lodash', 'moment', 'mapbox-gl', 'chartjs', 'randomcolor', 'knockout-paging'], ($, ko, _, moment, mapboxgl, Chart, randomColor) ->
  class ViewModel
    MAPBOX_ACCESS_TOKEN: 'pk.eyJ1IjoiYnJlbm5hbm5lb2giLCJhIjoiY2lyMDRjaXZrMDJweWZwbWd5d3JrNmR0MSJ9.Cek0zIm8OfVVY2pnyiRqVw'
    constructor: () ->
      @activitiesData = ko.observableArray()
      @activitiesData.extend
        paged:
          pageSize: 5
      @totalDistanceGroupedByMonth = ko.pureComputed => @_totalDistanceByMonth()
      @activitiesMonthYears = ko.pureComputed => @_activitiesMonthYears()
      @totalDistanceByCyclistAndMonth = ko.pureComputed => @_totalDistanceByCyclistAndMonth()

      @map = undefined

      @_loadData().then =>
        @_totalDistanceByCyclistAndMonth()
        @_loadMap()
        @_loadDistanceByMonthBarChart()

    _loadMap: ->
      mapboxgl.accessToken = @MAPBOX_ACCESS_TOKEN
      @map = new mapboxgl.Map
        container: 'map'
        style: 'mapbox://styles/mapbox/streets-v9'
        center: [103.7775, 1.3484]
        zoom: 12
      @map.on 'load', =>
        @_loadMapData()

    _loadMapData: ->
      data = @activitiesData()
      datumLimit = if data.length > 5 then 4 else data.length - 1
      [0..datumLimit].forEach (index) =>
        item = data[index]
        @map.addSource "route-#{item.id}",
          type: 'geojson'
          data:
            type: 'Feature'
            properties: {}
            geometry:
              type: 'LineString'
              coordinates: item.summary_coordinates
        @map.addLayer
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
      distanceData = _.values @totalDistanceGroupedByMonth()
      cyclists = ['brennanneoh', 'ranhiru']
      distanceByCyclistMonth = @totalDistanceByCyclistAndMonth()
      datasets = []
      cyclists.forEach (cyclist) =>
        cyclistDistanceData = []
        @activitiesMonthYears().forEach (monthYear) =>
          cyclistDistanceData.push distanceByCyclistMonth[monthYear][cyclist]
        data =
          label: cyclist
          backgroundColor: randomColor()
          data: cyclistDistanceData
        datasets.push(data)
      datasets.push
        label: 'Total'
        backgroundColor: randomColor()
        data: distanceData
      debugger
      labels = @activitiesMonthYears()
      data =
        labels: labels
        datasets: datasets
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

    _totalDistanceByCyclistAndMonth: ->
      totalDistanceByCyclistAndMonth = {}
      @activitiesMonthYears().forEach (monthYear) =>
        totalDistanceByCyclistAndMonth[monthYear] ||= {}
        ['brennanneoh', 'ranhiru'].forEach (cyclist) =>
          cyclistData = _.filter @activitiesData(), (data) =>
            data.athlete.username is cyclist
          totalDistanceByCyclistAndMonth[monthYear][cyclist] ||= 0
          cyclistData.forEach (item) =>
            itemMonthYear = moment(item.start_date).format 'MMMM YYYY'
            if monthYear is itemMonthYear
              distance = item.distance / 1000
              totalDistanceByCyclistAndMonth[monthYear][cyclist] += distance
          totalDistanceByCyclistAndMonth[monthYear][cyclist] = totalDistanceByCyclistAndMonth[monthYear][cyclist].toFixed(1)
      totalDistanceByCyclistAndMonth

    _formatSpeed: (speed) ->
      speed = speed * 3600 / 1000
      "#{speed.toFixed(1)} km/h"
