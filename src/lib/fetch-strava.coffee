require('dotenv').config()
strava = require 'strava-v3'
fs = require 'fs'
moment = require 'moment'
afterDate = moment('20160412').format 'X'
jsonfile = require 'jsonfile'

strava.athlete.listActivities { after: afterDate, per_page: 200 }, (err, payload) ->
  console.log 'querying /athletes/activities'
  if not err
    fs.writeFile 'data/strava-brennanneoh.json', JSON.stringify(payload), (err) ->
      throw err if err
      console.log 'saved /atheletes/activities'
  else
    throw err

strava.activities.listFriends { after: afterDate, per_page: 200 }, (err, payload) ->
  console.log 'querying /activities/following'
  jsonfile.writeFile 'data/strava-following.json', payload, (err) ->
    if err
      console.error err
    else
      console.log 'saved /activities/following'

