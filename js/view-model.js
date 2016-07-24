(function() {
  define('viewModel', ['jquery', 'knockout', 'lodash', 'moment', 'knockout-paging'], function($, ko, _, moment) {
    var viewModel;
    return viewModel = (function() {
      function viewModel() {
        this.activitiesData = ko.observableArray();
        this.activitiesData.extend({
          paged: {
            pageSize: 15
          }
        });
        this._loadData();
      }

      viewModel.prototype._loadData = function() {
        var json;
        json = $.ajax('js/activities.json');
        return json.done((function(_this) {
          return function(data) {
            var distance, i, item, len;
            for (i = 0, len = data.length; i < len; i++) {
              item = data[i];
              item.date = moment(item.start_date).format('MMMM Do YYYY');
              item.time = moment(item.start_date_local).parseZone(item.timezone).format('HH:mm:ss');
              distance = item.distance / 1000;
              item.distance = (distance.toFixed(1)) + " km";
              item.average_speed = _this._formatSpeed(item.average_speed);
              item.max_speed = _this._formatSpeed(item.max_speed);
            }
            data = _.orderBy(data, ['start_date', 'start_date_local'], ['desc', 'desc']);
            return _this.activitiesData(data);
          };
        })(this));
      };

      viewModel.prototype._formatSpeed = function(speed) {
        speed = speed * 3600 / 1000;
        return (speed.toFixed(1)) + " km/h";
      };

      return viewModel;

    })();
  });

}).call(this);
