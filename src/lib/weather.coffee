_ = require 'lodash'
moment = require 'moment'
require 'moment-range'
request = require 'request'
fs = require 'fs'
iconv = require 'iconv-lite'

weatherStations =
  clementi:
    code: 'S50'
  ulu_pandan:
    code: 'S35'
  choa_chu_kang:
    code: 'S114'
  bukit_panjang:
    code: 'S64'

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
  readStream.pipe iconv.decodeStream('iso-8859-1')
  readStream.pipe writeStream
# writeStream = fs.createWriteStream 'weather.csv'
# request = request.get 'http://www.weather.gov.sg/files/dailydata/DAILYDATA_S50_201604.csv'
# request.pipe writeStream
