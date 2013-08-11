soundcloud = require '../lib/soundcloud'

module.exports = (app) ->
  app.get '/login', (req, res) ->
    res.redirect soundcloud.authorizeUrl()

  app.get '/soundcloud_callback', (req, res) ->
    code = req.param 'code', null

    if not code
      req.flash 'error', 'Error logging in. Please try again.'
      res.redirect '/'
      return

    soundcloud.exchangeToken code, (token) ->
      soundcloud.request 'GET', '/me', token, (result) ->
        req.session.user = result.id
        userDetails = {
          id: result.id
          username: result.username
          token: token
        }
        res.redirect '/'
        res.end()
