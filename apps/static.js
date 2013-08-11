/* static routes */

var routes = function(app) {

  app.get('/', function(req, res) {
    res.render('index');
  });

  app.get('/upload', function(req, res) {
    res.render('upload', {
      username: req.session.username
    });
  });

  app.get('/about', function(req, res) {
    res.render('about');
  });
};

module.exports = routes;

