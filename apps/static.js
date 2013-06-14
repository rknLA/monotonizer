/* static routes */

var routes = function(app) {

  app.get('/', function(req, res) {
    res.render('index');
  });

  app.get('/about', function(req, res) {
    res.render('about');
  });
};

module.exports = routes;

