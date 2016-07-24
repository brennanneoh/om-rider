requirejs.config
  baseUrl: 'js/'
  paths:
    jquery: 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.0/jquery.min'
    knockout: 'https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.0/knockout-min'
    'knockout-paging': 'https://cdnjs.cloudflare.com/ajax/libs/knockout-paging/0.3.2/knockout-paging.min'
    lodash: 'https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.13.1/lodash.min'
    'mapbox-gl': 'https://api.mapbox.com/mapbox-gl-js/v0.21.0/mapbox-gl'
    moment: 'https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.14.1/moment.min'
    chartjs: 'https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.1.6/Chart.min'
    viewModel: 'view-model'

requirejs ['knockout', 'viewModel'], (ko, viewModel) ->
  ko.applyBindings(new viewModel())
