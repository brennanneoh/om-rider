require('dotenv').config()
strava = require 'strava-v3'
fs = require 'fs'

module.exports = (grunt) ->
  grunt.registerTask 'strava', 'Retrieve strava activities from API', () ->
    strava.athlete.listActivities {}, (err, payload) ->
      grunt.log.writeln 'querying /athletes/activities'
      if not err
        fs.writeFile 'data/strava-brennanneoh.json', JSON.stringify(payload), (err) ->
          grunt.fail.warn(err) if err
          grunt.log.writeln 'saved /atheletes/activities'
      else
        grunt.fail.warn err
