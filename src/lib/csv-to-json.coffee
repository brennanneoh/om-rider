fs = require 'fs'
csv = require 'fast-csv'
_ = require 'lodash'
jsonfile = require 'jsonfile'

fs.readdir 'data', (err, files) ->
  csvFiles = files.filter (file) -> file.substr(-4) == '.csv'
  stationMonthData = []
  csvFiles.forEach (file) ->
    monthData = []
    readStream = fs.createReadStream "data/#{file}"
    console.log "Reading from #{file}"
    csv.fromStream readStream, { headers: true }
       .on 'data', (datum) ->
         datum = _.pick datum, [
           'Station'
           'Year'
           'Month'
           'Day'
           'Daily Rainfall Total (mm)'
           'Highest 30 Min Rainfall (mm)'
           'Highest 60 Min Rainfall (mm)'
           'Highest 120 Min Rainfall (mm)'
         ]
         monthData.push datum
       .on 'end', () ->
         stationMonthData.push monthData
         if stationMonthData.length is csvFiles.length
           stationMonthData = _.flatten stationMonthData
           console.log 'Writing JSON file'
           jsonfile.writeFile 'build/js/weather.json', stationMonthData
