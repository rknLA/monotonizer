User = require '../../models/user'

routes = (app) ->
  app.post '/users', (req, res) ->
    accepted = req.get 'Accept'
    if accepted == 'application/json'
      User.register {ip: req.ip}, (newUser) ->
        if newUser
          res.status 201
          res.json newUser
        else
          res.status 422
          res.send "Server error creating a new user"
    else
      res.status 406 # not acceptable
      res.send()

module.exports = routes
