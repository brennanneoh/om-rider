define [
  'viewmodel'
  'jquery'
  'chartjs'
  'randomcolor'
  'moment'
  'jasmine-boot'
], (ViewModel, $, Chart, randomColor, moment) ->
  describe 'ViewModel', ->
    viewModel = new ViewModel()

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
      beforeEach ->
        spyOn($, 'ajax').and.callFake (req) ->
          deferred = $.Deferred()
          deferred.resolve fakeData
          deferred.promise()
        viewModel._loadData()

      it 'should call the ajax function', ->
        expect($.ajax).toHaveBeenCalledWith 'js/activities.json'

      it 'should set the data to `activitiesData`', (done) ->
        setTimeout ->
          expect(viewModel.activitiesData().length).toEqual 1
          done()
        , 10
