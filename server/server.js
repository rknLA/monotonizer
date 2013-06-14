
/**
 * Module dependencies.
 */

var express = require('express')
  , http = require('http')
  , path = require('path')
  , mongoose = require('mongoose')
  , keys = require('./keys');

require('coffee-script');

var app = module.exports = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser('your secret here'));
  app.use(express.session());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
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
require('./apps/videos/submission')(app);
require('./apps/videos/upvote')(app);
require('./apps/videos/queue')(app);
require('./apps/videos/presenter')(app);
require('./apps/users/create')(app);
require('./apps/search/video_search')(app);


http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});


