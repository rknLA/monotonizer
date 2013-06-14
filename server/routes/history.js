/*
 * GET history page.
 */

exports.history = function(req, res){
  res.render('history', { title: 'The Monotonizer' });
};
