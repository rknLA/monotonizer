/* static routes */

var routes = function(app) {

  app.get('/', function(req, res) {
    res.render('index', { title: 'The Monotonizer' });
  });

  app.get('/history', function(req, res) {
    res.render('history', { title: 'The Monotonizer' });
  });

  app.get('/about', function(req, res) {
    res.render('about', { title: 'The Monotonizer' });
  });
};

module.exports = routes;

