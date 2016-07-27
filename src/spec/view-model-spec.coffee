define ['viewmodel', 'jquery', 'chartjs', 'randomcolor', 'moment', 'mapbox-gl', 'jasmine-boot'], (ViewModel, $, Chart, randomColor, moment, mapboxgl) ->
  describe 'ViewModel', ->
    viewModel = undefined
    fakeData = [
      {
        athlete:
          username: 'john'
        start_date: moment().weekday(1).toISOString()
        start_date_local: moment().weekday(1).toISOString()
        distance: 5000
        average_speed: 20
        max_speed: 30
      }
    ]
    mapOn = undefined

    beforeEach ->
      spyOn($, 'ajax').and.callFake (req) ->
        deferred = $.Deferred()
        deferred.resolve fakeData
        deferred.promise()
      mapOn = jasmine.createSpy 'mapOn'
      spyOn(mapboxgl, 'Map').and.returnValue { on: mapOn }
      viewModel = new ViewModel()

    describe '_loadMap', ->
      it 'should have called `mapboxgl.Map` with options', (done) ->
        setTimeout ->
          expect(mapboxgl.Map).toHaveBeenCalledWith
            container: 'map'
            style: 'mapbox://styles/mapbox/streets-v9'
            center: [103.7775, 1.3484]
            zoom: 12
          done()
        , 30

      it 'should have called the `map.on` function in map', (done) ->
        setTimeout ->
          expect(mapOn).toHaveBeenCalled()
          done()
        , 30

    describe '_loadMapData', ->
      fakeActivitiesData = [
        {
          id: 1
          summary_coordinates: [
            [1, 2]
            [3, 4]
          ]
        }
        {
          id: 2
          summary_coordinates: [
            [5, 6]
            [7, 8]
          ]
        }
      ]
      addSource = undefined
      addLayer = undefined

      beforeEach ->
        spyOn(viewModel, 'activitiesData').and.returnValue fakeActivitiesData
        addSource = jasmine.createSpy 'addSource'
        addLayer = jasmine.createSpy 'addLayer'
        viewModel.map = {
          addSource: addSource
          addLayer: addLayer
        }
        viewModel._loadMapData()

      it 'should add a source to mapbox', ->
        expect(addSource).toHaveBeenCalledWith "route-#{fakeActivitiesData[0].id}",
          type: 'geojson'
          data:
            type: 'Feature'
            properties: {}
            geometry:
              type: 'LineString'
              coordinates: [ [1, 2], [3, 4] ]

    describe '_loadDistanceByMonthBarChart', ->
      canvasId = 'distance-by-month'
      fakeCanvas = document.createElement 'canvas'
      fakeTotalDistanceGroupedByMonth =
        'May 2016': 10
        'June 2016': 20
        'July 2016': 30
      fakeDataLabels = Object.keys fakeTotalDistanceGroupedByMonth
      fakeDatasetOneData = _.values fakeTotalDistanceGroupedByMonth

      beforeEach ->
        fakeCanvas.setAttribute 'id', canvasId
        document.body.appendChild fakeCanvas
        spyOn(viewModel, 'totalDistanceGroupedByMonth').and.returnValue fakeTotalDistanceGroupedByMonth
        spyOn(viewModel, 'activitiesMonthYears').and.returnValue fakeDataLabels

      afterEach ->
        fakeCanvas.remove()

      it 'should load the ChartJS object', ->
        chart = viewModel._loadDistanceByMonthBarChart()
        expect(chart.chart).toEqual jasmine.any(Chart)
        expect(chart.chart.canvas.id).toEqual canvasId
        expect(chart.config.type).toEqual 'horizontalBar'
        expect(chart.data.labels).toEqual fakeDataLabels
        expect(chart.data.datasets.length).toEqual 1
        expect(chart.data.datasets[0].data).toEqual fakeDatasetOneData

    describe '_loadData', ->
      it 'should call the ajax function', (done) ->
        setTimeout ->
          expect($.ajax).toHaveBeenCalledWith 'js/activities.json'
          done()
        , 10

      it 'should set the data to `activitiesData`', (done) ->
        setTimeout ->
          expect(viewModel.activitiesData().length).toEqual 1
          done()
        , 10

    describe '_formatSpeed', ->
      it 'should convert m/s to km/h, then append "km/h"', ->
        expect(viewModel._formatSpeed(10)).toEqual '36.0 km/h'
