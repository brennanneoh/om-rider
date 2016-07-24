(function() {
  requirejs.config({
    baseUrl: 'js/',
    paths: {
      jquery: 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.0/jquery.min',
      knockout: 'https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.0/knockout-min',
      lodash: 'https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.13.1/lodash.min',
      moment: 'https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.14.1/moment.min',
      'knockout-paging': 'https://cdnjs.cloudflare.com/ajax/libs/knockout-paging/0.3.2/knockout-paging.min',
      viewModel: 'view-model'
    }
  });

  requirejs(['knockout', 'viewModel'], function(ko, viewModel) {
    return ko.applyBindings(new viewModel());
  });

}).call(this);
