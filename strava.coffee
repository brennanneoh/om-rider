require('dotenv').config()

strava = require 'strava-v3'
fs = require 'fs'

strava.athlete.listActivities {}, (err, payload) ->
  console.log 'querying /athletes/activities'
  if not err
    fs.writeFile 'data/strava-brennanneoh.json', JSON.stringify(payload), (err) ->
      throw err if err
      console.log 'saved /atheletes/activities'
  else
    console.log err
