(function() {
  define('viewModel', ['jquery', 'knockout', 'lodash', 'moment'], function($, ko, _, moment) {
    var viewModel;
    return viewModel = (function() {
      function viewModel() {
        this.activitiesData = ko.observableArray();
        this._loadData();
      }

      viewModel.prototype._loadData = function() {
        var json;
        json = $.ajax('js/activities.json');
        return json.done((function(_this) {
          return function(data) {
            var average_speed, distance, i, item, len;
            for (i = 0, len = data.length; i < len; i++) {
              item = data[i];
              distance = item.distance / 1000;
              item.distance = (distance.toFixed(1)) + " km";
              average_speed = item.average_speed * 3600 / 1000;
              item.average_speed = (average_speed.toFixed(1)) + " km/h";
            }
            return _this.activitiesData(data);
          };
        })(this));
      };

      return viewModel;

    })();
  });

}).call(this);
