// import the used packages
var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');


// Create routes to different subdirectories
var indexRouter = require('./routes/index');
var docsRouter = require('./routes/docs');
var helpRouter = require('./routes/help');
var editorRouter = require('./routes/editor');
var compileRouter = require('./routes/compile');
var examplesRouter = require('./routes/examples');

// Parser for server requests
var bodyParser = require('body-parser');

// The network
var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

// setup the server request parser
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.json({type: 'application/vnd.api+json'}));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());

// Make the public directory usable for paths
app.use(express.static(path.join(__dirname, 'public')));

// route the subdirectories to the javascript route files
app.use('/', indexRouter);
app.use('/docs', docsRouter);
app.use('/help', helpRouter);
app.use('/editor', editorRouter);
app.use('/compile', compileRouter);
app.use('/examples', examplesRouter);

// route the api to the docs
app.get('/api', (req, res, next) => {
  res.sendFile(path.join(__dirname, 'docs/html/index.html'));
});
app.get('/api/*', (req, res, next) => {
  res.sendFile(path.join(__dirname, `docs/html/${req.params["0"]}`));
});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

const navbar = require('./routes/navbar')

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error', navbar);
});

module.exports = app;
