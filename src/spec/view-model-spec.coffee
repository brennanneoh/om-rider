define [
  'viewmodel'
  'jquery'
  'chartjs'
  'randomcolor'
  'jasmine-boot'
], (ViewModel, $, Chart, randomColor) ->
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

      it 'should load the ChartJS object', ->
        chart = viewModel._loadDistanceByMonthBarChart()
        expect(chart.chart).toEqual jasmine.any(Chart)
        expect(chart.chart.canvas.id).toEqual canvasId
        expect(chart.config.type).toEqual 'horizontalBar'
        expect(chart.data.labels).toEqual fakeDataLabels
        expect(chart.data.datasets.length).toEqual 1
        expect(chart.data.datasets[0].data).toEqual fakeDatasetOneData

      afterEach ->
        fakeCanvas.remove()
