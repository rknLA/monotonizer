User = require '../../models/user'
Search = require '../../models/search'

routes = (app) ->
  app.get '/search', (req, res) ->
    accepted = req.get 'Accept'
    if accepted == 'application/json'
      User.authenticate req, (currentUser) ->
        if currentUser
          # new search
          Search.createWithQuery
            q: req.query.q
            googleApiKey: app.settings.googleApiKey
            user_id: currentUser._id
            (results) ->
              res.status 201
              results.next = req.url
              res.json results
        else
          res.status 401 # unauthorized
          res.send()
    else
      res.status 406 # not acceptable
      res.send()

module.exports = routes

