_ = require 'lodash'
jsonfile = require 'jsonfile'
selfJson = require '../data/strava-brennanneoh.json'
followJson = require '../data/strava-following.json'
polyline = require 'polyline'
randomColor = require 'randomcolor'

module.exports = (grunt) ->
  grunt.registerTask 'activities', 'Generates activities from downloaded strava JSON files', () ->
    _.map selfJson, (data) ->
      data.athlete =
        username: 'brennanneoh'
    dataJson = _.union selfJson, followJson
    selectedData = _.map dataJson, (data) ->
      if not _.isEmpty(data.map.summary_polyline)
        decodedData = polyline.decode data.map.summary_polyline
        data.summary_coordinates = _.map decodedData, (item) -> [item[1], item[0]]
        data.line_color = randomColor()
      _.pick data, [
        'id'
        'athlete'
        'name'
        'distance'
        'moving_time'
        'elapsed_time'
        'start_date'
        'start_date_local'
        'start_latlng'
        'end_latlng'
        'summary_coordinates'
        'line_color'
        'commute'
        'average_speed'
        'max_speed'
        'elev_high'
        'elev_low'
      ]
    selectedData = _.filter selectedData, (data) ->
      _.includes ['brennanneoh', 'ranhiru'], data.athlete.username
    selectedData = _.uniqBy selectedData, 'id'
    grunt.file.write 'build/js/activities.json', JSON.stringify(selectedData)
