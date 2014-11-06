gulp = require('gulp')
gutil = require('gulp-util')
coffee = require('gulp-coffee')
uglify = require('gulp-uglify')
rename = require('gulp-rename')

gulp.task 'build', ->
  gulp.src('src/*.coffee')
    .pipe(coffee(bare: false).on('error', gutil.log))
    .pipe(gulp.dest('lib/'))

gulp.task 'minify', ['build'], ->
  gulp.src('lib/*.js')
    .pipe(uglify(outSourceMap: false))
    .pipe(rename(suffix: '.min'))
    .pipe(gulp.dest('dist/'))

gulp.task 'prepare', ['build', 'minify']
