(function() {
  require(['config'], function() {
    return require(['knockout', 'viewmodel'], function(ko, ViewModel) {
      return ko.applyBindings(new ViewModel());
    });
  });

}).call(this);
