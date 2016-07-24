module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'build/js/main.js': 'src/coffee/main.coffee'
          'build/js/view-model.js': 'src/coffee/view-model.coffee'
    sass:
      compile:
        files:
          'build/css/main.css': 'src/scss/main.scss'
    pug:
      compile:
        files:
          'build/index.html': 'src/index.pug'
    copy:
      main:
        files:
          'build/CNAME': 'src/CNAME'
    connect:
      server:
        options:
          port: 8000
          base: 'build'
    watch:
      coffee:
        files: ['src/coffee/*.coffee']
        tasks: ['coffee']
      sass:
        files: ['src/scss/main.scss']
        tasks: ['sass']
      pug:
        files: ['src/*.pug']
        tasks: ['pug']
    'gh-pages':
      options:
        base: 'build'
      src: ['**']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-pug'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-curl'
  grunt.loadNpmTasks 'grunt-gh-pages'

  grunt.loadTasks 'tasks'

  grunt.registerTask 'compile', ['coffee', 'pug', 'sass']
  grunt.registerTask 'server', ['compile', 'connect', 'watch']
