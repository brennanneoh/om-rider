bowerRequireJS = require 'bower-requirejs'
pug = require 'pug'

exports.process = (grunt, task, context) ->
  options =
    config: 'spec/config.js'
    exclude: 'jasmine'
    baseUrl: '.'

  bowerRequireJS options, (rjsConfig) ->
    console.log rjsConfig

  source = grunt.file.read 'src/specrunner.pug'
  pug.render source
