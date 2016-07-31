(function() {
  define('viewmodel', ['jquery', 'knockout', 'lodash', 'moment', 'mapbox-gl', 'chartjs', 'randomcolor', 'moment-range'], function($, ko, _, moment, mapboxgl, Chart, randomColor) {
    var ViewModel;
    return ViewModel = (function() {
      ViewModel.prototype.MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoiYnJlbm5hbm5lb2giLCJhIjoiY2lyMDRjaXZrMDJweWZwbWd5d3JrNmR0MSJ9.Cek0zIm8OfVVY2pnyiRqVw';

      function ViewModel() {
        this.activitiesData = ko.observableArray();
        this.weatherData = ko.observableArray();
        this.thisWeekData = ko.observableArray();
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
        this.totalDistanceByCyclistAndMonth = ko.pureComputed((function(_this) {
          return function() {
            return _this._totalDistanceByCyclistAndMonth();
          };
        })(this));
        this.rainfallData = ko.pureComputed((function(_this) {
          return function() {
            return _this._loadRainfallData();
          };
        })(this));
        this.mondayOfLatestWeek = ko.observable();
        this.fridayOfLatestWeek = ko.observable();
        this.thisWeekTitle = ko.pureComputed((function(_this) {
          return function() {
            return "This Week (" + (_this.mondayOfLatestWeek()) + " to " + (_this.fridayOfLatestWeek()) + ")";
          };
        })(this));
        this.map = void 0;
        this._loadWeatherData().then((function(_this) {
          return function() {
            return _this._loadData().then(function() {
              _this._loadMap();
              _this._loadDistanceByMonthBarChart();
              return _this._loadThisWeekData();
            });
          };
        })(this));
      }

      ViewModel.prototype._loadWeatherData = function() {
        var json, weatherGroupedByDate;
        json = $.ajax('js/weather.json');
        weatherGroupedByDate = {};
        return json.then((function(_this) {
          return function(data) {
            var datum, datumDate, i, len, name;
            for (i = 0, len = data.length; i < len; i++) {
              datum = data[i];
              datumDate = moment(datum.Year + "-" + datum.Month + "-" + datum.Day, 'YYYY-MM-DD');
              weatherGroupedByDate[name = datumDate.format('YYYY-MM-DD')] || (weatherGroupedByDate[name] = []);
              weatherGroupedByDate[datumDate.format('YYYY-MM-DD')].push(_.pick(datum, ['Station', 'Daily Rainfall Total (mm)']));
            }
            return _this.weatherData(weatherGroupedByDate);
          };
        })(this));
      };

      ViewModel.prototype._loadRainfallData = function() {
        var rainfallData, weatherDates;
        rainfallData = {};
        weatherDates = Object.keys(this.weatherData());
        weatherDates.forEach((function(_this) {
          return function(datumDate) {
            var rainfall, stationData, stationWithMaxRainfall;
            stationData = _this.weatherData()[datumDate];
            rainfall = [];
            stationData.forEach(function(stationDatum) {
              return rainfall.push(stationDatum['Daily Rainfall Total (mm)']);
            });
            stationWithMaxRainfall = _.find(stationData, function(station) {
              return station['Daily Rainfall Total (mm)'] === _.max(rainfall);
            });
            return rainfallData[datumDate] = {
              rainfall: rainfall,
              max_total_rainfall: _.max(rainfall),
              max_total_rainfall_station: stationWithMaxRainfall['Station']
            };
          };
        })(this));
        return rainfallData;
      };

      ViewModel.prototype._loadThisWeekData = function() {
        var data, datum, fridayOfLatestWeek, groupedByDay, i, latestDate, latestWeek, len, mondayOfLatestWeek;
        data = _.orderBy(this.activitiesData(), ['start_date_local'], ['desc']);
        latestDate = data[0].start_date;
        mondayOfLatestWeek = moment(latestDate).startOf('isoWeek');
        this.mondayOfLatestWeek(mondayOfLatestWeek.format('MMMM Do'));
        fridayOfLatestWeek = moment(latestDate).startOf('isoWeek').add(4, 'days');
        this.fridayOfLatestWeek(fridayOfLatestWeek.format('MMMM Do'));
        latestWeek = moment.range(mondayOfLatestWeek, fridayOfLatestWeek.add(23, 'hours'));
        data = _.filter(data, function(datum) {
          return latestWeek.contains(moment(datum.start_date_local));
        });
        for (i = 0, len = data.length; i < len; i++) {
          datum = data[i];
          datum.avatar_url = "https://github.com/" + datum.athlete.username + ".png?size=20";
          datum.date = moment(datum.start_date_local).format('MMMM Do');
          datum.time = moment(datum.start_date_local).parseZone(datum.timezone).format('HH:mm:ss');
          datum.distance_kilometer = this._formatDistance(datum.distance);
          datum.average_speed = this._formatSpeed(datum.average_speed);
          datum.max_speed = this._formatSpeed(datum.max_speed);
        }
        groupedByDay = [];
        latestWeek.by('days', function(moment) {
          var dateOfWeek, dayData;
          dateOfWeek = moment.format('MMMM Do');
          dayData = _.filter(data, function(datum) {
            return datum.date === dateOfWeek;
          });
          return groupedByDay.push({
            date: dateOfWeek,
            activities: dayData
          });
        });
        groupedByDay = _.orderBy(groupedByDay, ['date'], ['desc']);
        return this.thisWeekData(groupedByDay);
      };

      ViewModel.prototype._loadMap = function() {
        mapboxgl.accessToken = this.MAPBOX_ACCESS_TOKEN;
        this.map = new mapboxgl.Map({
          container: 'map',
          style: 'mapbox://styles/mapbox/streets-v9',
          center: [103.7775, 1.3484],
          zoom: 12
        });
        return this.map.on('load', (function(_this) {
          return function() {
            return _this._loadMapData();
          };
        })(this));
      };

      ViewModel.prototype._loadMapData = function() {
        var data;
        data = _.orderBy(this.activitiesData(), ['start_date_local'], ['desc']);
        return [0, 1].forEach((function(_this) {
          return function(index) {
            var item;
            item = data[index];
            _this.map.addSource("route-" + item.id, {
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
            return _this.map.addLayer({
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
          };
        })(this));
      };

      ViewModel.prototype._loadData = function() {
        var json;
        json = $.ajax('js/activities.json');
        return json.then((function(_this) {
          return function(data) {
            var endDateOfLatestWeek, latestDate, latestWeek, startDateOfLatestWeek;
            _this.activitiesData(data);
            data = _.orderBy(data, ['start_date', 'start_date_local'], ['desc', 'desc']);
            latestDate = data[0].start_date;
            startDateOfLatestWeek = moment(latestDate).startOf('isoWeek');
            endDateOfLatestWeek = moment(latestDate).endOf('isoWeek');
            latestWeek = moment.range(startDateOfLatestWeek, endDateOfLatestWeek);
            return data = _.filter(data, function(datum) {
              var isLatestWeek, isWeekday;
              isLatestWeek = latestWeek.contains(moment(datum.start_date));
              isWeekday = _.includes([1, 2, 3, 4, 5], moment(datum.start_date_local).isoWeekday());
              return isLatestWeek && isWeekday;
            });
          };
        })(this));
      };

      ViewModel.prototype._formatDistance = function(distance) {
        distance = distance / 1000;
        return (distance.toFixed(1)) + " km";
      };

      ViewModel.prototype._loadDistanceByMonthBarChart = function() {
        var context, cyclists, data, datasets, distanceByCyclistMonth, distanceByMonthChart, distanceData, labels;
        distanceData = _.values(this.totalDistanceGroupedByMonth());
        cyclists = ['brennanneoh', 'ranhiru'];
        distanceByCyclistMonth = this.totalDistanceByCyclistAndMonth();
        datasets = [];
        cyclists.forEach((function(_this) {
          return function(cyclist) {
            var cyclistDistanceData, data;
            cyclistDistanceData = [];
            _this.activitiesMonthYears().forEach(function(monthYear) {
              return cyclistDistanceData.push(distanceByCyclistMonth[monthYear][cyclist]);
            });
            data = {
              label: cyclist,
              backgroundColor: randomColor({
                hue: 'blue'
              }),
              data: cyclistDistanceData
            };
            return datasets.push(data);
          };
        })(this));
        labels = this.activitiesMonthYears();
        data = {
          labels: labels,
          datasets: datasets
        };
        context = $('#distance-by-month');
        return distanceByMonthChart = new Chart(context, {
          type: 'horizontalBar',
          data: data,
          options: {
            scales: {
              xAxes: [
                {
                  stacked: true
                }
              ],
              yAxes: [
                {
                  gridLines: {
                    display: false,
                    zeroLineWidth: 0
                  },
                  stacked: true
                }
              ]
            }
          }
        });
      };

      ViewModel.prototype._activitiesMonthYears = function() {
        var monthYears;
        monthYears = _.map(this.activitiesData(), function(data) {
          return moment(data.start_date).format('MMMM YYYY');
        });
        return _.uniq(monthYears);
      };

      ViewModel.prototype._totalDistanceByMonth = function() {
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

      ViewModel.prototype._totalDistanceByCyclistAndMonth = function() {
        var totalDistanceByCyclistAndMonth;
        totalDistanceByCyclistAndMonth = {};
        this.activitiesMonthYears().forEach((function(_this) {
          return function(monthYear) {
            totalDistanceByCyclistAndMonth[monthYear] || (totalDistanceByCyclistAndMonth[monthYear] = {});
            return ['brennanneoh', 'ranhiru'].forEach(function(cyclist) {
              var base, cyclistData;
              cyclistData = _.filter(_this.activitiesData(), function(data) {
                return data.athlete.username === cyclist;
              });
              (base = totalDistanceByCyclistAndMonth[monthYear])[cyclist] || (base[cyclist] = 0);
              cyclistData.forEach(function(item) {
                var distance, itemMonthYear;
                itemMonthYear = moment(item.start_date).format('MMMM YYYY');
                if (monthYear === itemMonthYear) {
                  distance = item.distance / 1000;
                  return totalDistanceByCyclistAndMonth[monthYear][cyclist] += distance;
                }
              });
              return totalDistanceByCyclistAndMonth[monthYear][cyclist] = totalDistanceByCyclistAndMonth[monthYear][cyclist].toFixed(1);
            });
          };
        })(this));
        return totalDistanceByCyclistAndMonth;
      };

      ViewModel.prototype._formatSpeed = function(speed) {
        speed = speed * 3600 / 1000;
        return (speed.toFixed(1)) + " km/h";
      };

      return ViewModel;

    })();
  });

}).call(this);
