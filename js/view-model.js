(function() {
  define('viewModel', ['jquery', 'knockout', 'lodash', 'moment', 'mapbox-gl', 'chartjs', 'randomcolor', 'knockout-paging'], function($, ko, _, moment, mapboxgl, Chart, randomColor) {
    var viewModel;
    return viewModel = (function() {
      function viewModel() {
        this.activitiesData = ko.observableArray();
        this.activitiesData.extend({
          paged: {
            pageSize: 15
          }
        });
        this.totalDistanceGroupedByMonth = ko.pureComputed((function(_this) {
          return function() {
            return _this._totalDistanceByMonth();
          };
        })(this));
        this.activitiesMonthYears = ko.pureComputed((function(_this) {
          return function() {
            return _this._activitiesMonthYears();
          };
        })(this));
        this._loadData().then((function(_this) {
          return function() {
            _this._loadMap();
            return _this._loadDistanceByMonthBarChart();
          };
        })(this));
      }

      viewModel.prototype._loadMap = function() {
        var map;
        mapboxgl.accessToken = 'pk.eyJ1IjoiYnJlbm5hbm5lb2giLCJhIjoiY2lyMDRjaXZrMDJweWZwbWd5d3JrNmR0MSJ9.Cek0zIm8OfVVY2pnyiRqVw';
        map = new mapboxgl.Map({
          container: 'map',
          style: 'mapbox://styles/mapbox/streets-v9',
          center: [103.7775, 1.3484],
          zoom: 12
        });
        return map.on('load', (function(_this) {
          return function() {
            var data;
            data = _this.activitiesData();
            return [0, 1, 2, 3, 4].forEach(function(index) {
              var item;
              item = data[index];
              map.addSource("route-" + item.id, {
                type: 'geojson',
                data: {
                  type: 'Feature',
                  properties: {},
                  geometry: {
                    type: 'LineString',
                    coordinates: item.summary_coordinates
                  }
                }
              });
              return map.addLayer({
                id: "route-" + item.id,
                type: 'line',
                source: "route-" + item.id,
                layout: {
                  'line-join': 'round',
                  'line-cap': 'round'
                },
                paint: {
                  'line-color': item.line_color,
                  'line-width': 5
                }
              });
            });
          };
        })(this));
      };

      viewModel.prototype._loadData = function() {
        var json;
        json = $.ajax('js/activities.json');
        return json.then((function(_this) {
          return function(data) {
            var distance, i, item, len;
            for (i = 0, len = data.length; i < len; i++) {
              item = data[i];
              item.avatar_url = "https://github.com/" + item.athlete.username + ".png?size=20";
              item.date = moment(item.start_date).format('MMMM Do');
              item.time = moment(item.start_date_local).parseZone(item.timezone).format('HH:mm:ss');
              distance = item.distance / 1000;
              item.distance_kilometer = (distance.toFixed(1)) + " km";
              item.average_speed = _this._formatSpeed(item.average_speed);
              item.max_speed = _this._formatSpeed(item.max_speed);
            }
            data = _.orderBy(data, ['start_date', 'start_date_local'], ['desc', 'desc']);
            return _this.activitiesData(_.filter(data, function(item) {
              return _.includes([1, 2, 3, 4, 5], moment(item.start_date_local).isoWeekday());
            }));
          };
        })(this));
      };

      viewModel.prototype._loadDistanceByMonthBarChart = function() {
        var backgroundColor, context, data, distanceByMonthChart, distanceData, labels;
        backgroundColor = _.times(_.size(this.totalDistanceGroupedByMonth()), function() {
          return randomColor();
        });
        distanceData = _.values(this.totalDistanceGroupedByMonth());
        labels = this.activitiesMonthYears();
        data = {
          labels: labels,
          datasets: [
            {
              label: 'Total',
              backgroundColor: backgroundColor,
              data: distanceData
            }
          ]
        };
        context = $('#distance-by-month');
        return distanceByMonthChart = new Chart(context, {
          type: 'horizontalBar',
          data: data,
          options: {
            maintainAspectRation: true
          }
        });
      };

      viewModel.prototype._activitiesMonthYears = function() {
        var monthYears;
        monthYears = _.map(this.activitiesData(), function(data) {
          return moment(data.start_date).format('MMMM YYYY');
        });
        return _.uniq(monthYears);
      };

      viewModel.prototype._totalDistanceByMonth = function() {
        var totalDistanceByMonth;
        totalDistanceByMonth = {};
        this.activitiesData().forEach((function(_this) {
          return function(item) {
            var itemMonthYear;
            itemMonthYear = moment(item.start_date).format('MMMM YYYY');
            totalDistanceByMonth[itemMonthYear] || (totalDistanceByMonth[itemMonthYear] = 0);
            if (_.includes(_this.activitiesMonthYears(), itemMonthYear)) {
              return totalDistanceByMonth[itemMonthYear] += item.distance / 1000;
            }
          };
        })(this));
        return _.map(totalDistanceByMonth, function(item) {
          return item.toFixed(1);
        });
      };

      viewModel.prototype._formatSpeed = function(speed) {
        speed = speed * 3600 / 1000;
        return (speed.toFixed(1)) + " km/h";
      };

      return viewModel;

    })();
  });

}).call(this);
