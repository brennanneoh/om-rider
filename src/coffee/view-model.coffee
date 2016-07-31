define 'viewmodel', ['jquery', 'knockout', 'lodash', 'moment', 'mapbox-gl', 'chartjs', 'randomcolor', 'moment-range'], ($, ko, _, moment, mapboxgl, Chart, randomColor) ->
  class ViewModel
    MAPBOX_ACCESS_TOKEN: 'pk.eyJ1IjoiYnJlbm5hbm5lb2giLCJhIjoiY2lyMDRjaXZrMDJweWZwbWd5d3JrNmR0MSJ9.Cek0zIm8OfVVY2pnyiRqVw'
    constructor: () ->
      @activitiesData = ko.observableArray()
      @weatherData = ko.observableArray()
      @thisWeekData = ko.observableArray()
      @totalDistanceGroupedByMonth = ko.pureComputed => @_totalDistanceByMonth()
      @activitiesMonthYears = ko.pureComputed => @_activitiesMonthYears()
      @totalDistanceByCyclistAndMonth = ko.pureComputed => @_totalDistanceByCyclistAndMonth()
      @rainfallData = ko.pureComputed => @_loadRainfallData()
      @mondayOfLatestWeek = ko.observable()
      @fridayOfLatestWeek = ko.observable()
      @thisWeekTitle = ko.pureComputed =>
        "This Week (#{@mondayOfLatestWeek()} to #{@fridayOfLatestWeek()})"

      @map = undefined

      @_loadWeatherData().then =>
        @_loadData().then =>
          @_loadMap()
          @_loadDistanceByMonthBarChart()
          @_loadThisWeekData()

    _loadWeatherData: ->
      json = $.ajax 'js/weather.json'
      weatherGroupedByDate = {}
      json.then (data) =>
        for datum in data
          datumDate = moment("#{datum.Year}-#{datum.Month}-#{datum.Day}", 'YYYY-MM-DD')
          weatherGroupedByDate[datumDate.format('YYYY-MM-DD')] ||= []
          weatherGroupedByDate[datumDate.format('YYYY-MM-DD')].push _.pick(datum, ['Station', 'Daily Rainfall Total (mm)'])
        @weatherData weatherGroupedByDate

    _loadRainfallData: ->
      rainfallData = {}
      weatherDates = Object.keys @weatherData()
      weatherDates.forEach (datumDate) =>
        stationData = @weatherData()[datumDate]
        rainfall = []
        stationData.forEach (stationDatum) ->
          rainfall.push(stationDatum['Daily Rainfall Total (mm)'])
        stationWithMaxRainfall = _.find stationData, (station) -> station['Daily Rainfall Total (mm)'] is _.max(rainfall)
        rainfallData[datumDate] =
          rainfall: rainfall
          max_total_rainfall: _.max rainfall
          max_total_rainfall_station: stationWithMaxRainfall['Station']
      rainfallData

    _loadThisWeekData: ->
      data = _.orderBy @activitiesData(), ['start_date', 'start_date_local'], ['desc', 'desc']
      latestDate = data[0].start_date
      mondayOfLatestWeek = moment(latestDate).startOf 'isoWeek'
      @mondayOfLatestWeek mondayOfLatestWeek.format('MMMM Do')
      fridayOfLatestWeek = moment(latestDate).startOf('isoWeek').add 4, 'days'
      @fridayOfLatestWeek fridayOfLatestWeek.format('MMMM Do')
      latestWeek = moment.range mondayOfLatestWeek, fridayOfLatestWeek.add(23,'hours')
      data = _.filter data, (datum) ->
        latestWeek.contains moment(datum.start_date_local)
      for datum in data
        datum.avatar_url = "https://github.com/#{datum.athlete.username}.png?size=20"
        datum.date = moment(datum.start_date_local).format 'MMMM Do'
        datum.time = moment(datum.start_date_local).parseZone(datum.timezone).format 'HH:mm:ss'
        datum.distance_kilometer = @_formatDistance(datum.distance)
        datum.average_speed = @_formatSpeed(datum.average_speed)
        datum.max_speed = @_formatSpeed(datum.max_speed)

      groupedByDay = []
      latestWeek.by 'days', (moment) ->
        dateOfWeek = moment.format('MMMM Do')
        dayData = _.filter data, (datum) ->
          datum.date is dateOfWeek
        groupedByDay.push { date: dateOfWeek, activities: dayData }
      groupedByDay = _.orderBy groupedByDay, ['date'], ['desc']
      @thisWeekData groupedByDay

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
        @activitiesData data
        data = _.orderBy data, ['start_date', 'start_date_local'], ['desc', 'desc']
        latestDate = data[0].start_date
        startDateOfLatestWeek = moment(latestDate).startOf 'isoWeek'
        endDateOfLatestWeek = moment(latestDate).endOf 'isoWeek'
        latestWeek = moment.range startDateOfLatestWeek, endDateOfLatestWeek
        data = _.filter data, (datum) ->
          isLatestWeek = latestWeek.contains moment(datum.start_date)
          isWeekday = _.includes [1..5], moment(datum.start_date_local).isoWeekday()
          isLatestWeek and isWeekday

    _formatDistance: (distance) ->
      distance = distance / 1000
      "#{distance.toFixed(1)} km"

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
          backgroundColor: randomColor { hue: 'blue' }
          data: cyclistDistanceData
        datasets.push(data)
      labels = @activitiesMonthYears()
      data =
        labels: labels
        datasets: datasets
      context = $('#distance-by-month')
      distanceByMonthChart = new Chart context,
        type: 'horizontalBar'
        data: data
        options:
          scales:
            xAxes: [
              stacked: true
            ]
            yAxes: [
              gridLines:
                display: false
                zeroLineWidth: 0
              stacked: true
            ]

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
