module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'build/js/main.js': 'src/coffee/main.coffee'
          'build/js/view-model.js': 'src/coffee/view-model.coffee'
    pug:
      compile:
        files:
          'build/index.html': 'src/index.pug'
    connect:
      server:
        options:
          port: 8000
          base: 'build'
    watch:
      coffee:
        files: ['src/coffee/*.coffee']
        tasks: ['compile:coffee']
      pug:
        files: ['src/*.pug']
        tasks: ['compile:pug']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-pug'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-curl'

  grunt.loadTasks 'tasks'

  grunt.registerTask 'compile', ['coffee', 'pug']
  grunt.registerTask 'server', ['compile', 'connect', 'watch']
