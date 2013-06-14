
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'The Monotonizer' });
};

exports.history = function(req, res){
  res.render('history', { title: 'The Monotonizer' });
};

exports.about = function(req, res){
  res.render('about', { title: 'The Monotonizer' });
};
