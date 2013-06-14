
/**
 * Module dependencies.
 */

var express = require('express')
  , http = require('http')
  , fs = require('fs')
  , path = require('path')
  , mongoose = require('mongoose')
  , keys = require('./keys');

require('coffee-script');

/* create uploads folder if it doesn't exist */
var upload_path = path.join(__dirname, 'uploads');
fs.exists(upload_path, function(exists) {
  if (!exists) {
    fs.mkdir(upload_path, function(err) {
      if (err) {
        console.log("Error creating uploads folder.");
        throw(err);
      }
    });
  }
});

/* resume doing the app stuff */
var app = module.exports = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
  app.set('root', __dirname);
});

app.configure('development', function(){
  app.use(express.errorHandler());
  app.set('db', mongoose.connect('mongodb://localhost/cinema_dev'));
});

app.configure('test', function() {
  app.set('db', mongoose.connect('mongodb://localhost/cinema_test'));
});

app.configure('production', function() {
  app.set('db', mongoose.connect(keys.mongoUrl));
});

require('./apps/static')(app);
require('./apps/renderer')(app);
require('./apps/history')(app);

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});


