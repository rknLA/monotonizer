
/*
 * GET about page.
 */

exports.about = function(req, res){
  res.render('about', { title: 'The Monotonizer' });
};
