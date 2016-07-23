_ = require 'lodash'
dataJson = require '../data/strava-brennanneoh.json'

module.exports = (grunt) ->
  grunt.registerTask 'activities', 'Generates activities from downloaded strava JSON files', () ->
  selectedData = _.map dataJson, (data) ->
    _.pick data, [
      'id'
      'name'
      'distance'
      'moving_time'
      'elapsed_time'
      'start_date'
      'start_date_local'
      'start_latlng'
      'end_latlng'
      'map'
      'commute'
      'average_speed'
      'max_speed'
      'elev_high'
      'elev_low'
    ]
  grunt.file.write 'build/activities.json'
