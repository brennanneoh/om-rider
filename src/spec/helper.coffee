require ['../build/js/config'], ->
  require.config
    paths:
      jasmine: '//cdnjs.cloudflare.com/ajax/libs/jasmine/2.4.1/jasmine.min'
      'jasmine-html': '//cdnjs.cloudflare.com/ajax/libs/jasmine/2.4.1/jasmine-html.min'
      'jasmine-boot': '//cdnjs.cloudflare.com/ajax/libs/jasmine/2.4.1/boot.min'
      viewmodel: '../build/js/view-model'
    shim:
      'jasmine-html':
        deps: ['jasmine']
      'jasmine-boot':
        deps: ['jasmine-html']
  require ['view-model-spec'], () ->
    window.onload()
