module.exports = (config) ->
  config.set
    preprocessors: '**/*.coffee': ['coffee']
    basePath: ''
    frameworks: ['mocha', 'chai', 'chai-sinon']
    files: ['node_modules/backbone/node_modules/underscore/underscore.js', 'node_modules/backbone/backbone.js', 'src/*.coffee', 'spec/*_spec.coffee']
    exclude: []
    reporters: ['progress']
    port: 9876
    colors: true
    autoWatch: true
    browsers: ['PhantomJS']
    captureTimeout: 60000
    singleRun: false
