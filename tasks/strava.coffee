require('dotenv').config()
strava = require 'strava-v3'
fs = require 'fs'
moment = require 'moment'

module.exports = (grunt) ->
  grunt.registerTask 'strava', 'Retrieve strava activities from API', () ->
    afterDate = moment('20160411').format 'X'
    strava.athlete.listActivities { 'after': afterDate }, (err, payload) ->
      grunt.log.writeln 'querying /athletes/activities'
      if not err
        fs.writeFile 'data/strava-brennanneoh.json', JSON.stringify(payload), (err) ->
          grunt.fail.warn(err) if err
          grunt.log.writeln 'saved /atheletes/activities'
      else
        grunt.fail.warn err
