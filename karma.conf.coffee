module.exports = (config) ->
  config.set
    preprocessors: '**/*.coffee': ['coffee']
    basePath: ''
    frameworks: ['mocha', 'chai', 'chai-sinon']
    files: [
      'bower_components/underscore/underscore.js',
      'bower_components/backbone/backbone.js',
      'src/*.coffee',
      'spec/*_spec.coffee'
    ]
    exclude: []
    reporters: ['progress']
    port: 9876
    colors: true
    autoWatch: true
    browsers: ['PhantomJS']
    captureTimeout: 60000
    singleRun: false
