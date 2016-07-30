_ = require 'lodash'
moment = require 'moment'
require 'moment-range'
request = require 'request'
fs = require 'fs'

weatherStations =
  clementi:
    code: 'S50'
  ulu_pandan:
    code: 'S35'
  choa_chu_kang:
    code: 'S114'
  bukit_panjang:
    code: 'S64'
  botanic_gardens:
    code: 'S120'
  bukit_timah:
    code: 'S90'

startYearMonth = moment '2016-04-01', 'YYYY-MM-DD'
endYearMonth = moment().subtract(1, 'months').format 'YYYY-MM-DD'
rangeMonth = moment.range startYearMonth, endYearMonth

weatherCsvFiles = []
rangeMonth.by 'months', (yearMonth) ->
  yearMonth = yearMonth.format 'YYYYMM'
  weatherCsvFiles.push _.map weatherStations, (station) ->
    "data/DAILYDATA_#{station.code}_#{yearMonth}.csv": "http://www.weather.gov.sg/files/dailydata/DAILYDATA_#{station.code}_#{yearMonth}.csv"

weatherCsvFiles = _.reduce _.flatten(weatherCsvFiles), ((memo, current) ->
  _.extend memo, current
), {}

for csvFile of weatherCsvFiles
  writeStream = fs.createWriteStream csvFile, { encoding: 'binary' }
  readStream = request.get weatherCsvFiles[csvFile]
  console.log "Writing file #{csvFile}"
  readStream.pipe writeStream
