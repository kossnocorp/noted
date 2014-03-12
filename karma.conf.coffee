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
    captureTimeout: 60000
    singleRun: false

    sauceLabs:
      username: 'kossnocorp-noted'
      accessKey: '8f8692f8-e4c4-45ff-b8d2-1d5b482dc249'
      testName: 'Noted.js'

    customLaunchers:
      ie9:
        base: 'SauceLabs'
        browserName: 'internet explorer'
        version: 9
        platform: 'Windows 7'

    browsers: ['PhantomJS']
