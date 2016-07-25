module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        expand: true
        flatten: false
        cwd: 'src/coffee'
        src: ['**/*.coffee']
        dest: 'build/js'
        ext: '.js'
      test:
        expand: true
        flatten: false
        cwd: 'src/spec'
        src: ['**/*.coffee']
        dest: 'spec'
        ext: '.js'
      lib:
        expand: true
        flatten: false
        cwd: 'src/lib'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'
    sass:
      compile:
        files:
          'build/css/main.css': 'src/scss/main.scss'
    pug:
      compile:
        files:
          'build/index.html': 'src/index.pug'
      test:
        files:
          'specrunner.html': 'src/specrunner.pug'
    copy:
      main:
        files:
          'build/CNAME': 'src/CNAME'
    connect:
      build:
        options:
          port: 8000
          base: 'build'
      test:
        options:
          port: 8000
          base: '.'
          index: './specrunner.html'
    watch:
      coffee:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      sass:
        files: ['src/**/*.scss']
        tasks: ['sass']
      pug:
        files: ['src/**/*.pug']
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
  grunt.registerTask 'test', ['compile', 'connect:test', 'watch']
