User = require '../../models/user'
Video = require '../../models/video'

routes = (app) ->
  app.put '/videos/:video_id/play', (req, res) ->
    accepted = req.get('Accept')
    if accepted == 'application/json'
      User.authenticate req, (currentUser) ->
        if currentUser
          Video.play req.params.video_id, (err, video) ->
            throw err if err
            res.status 202
            res.json(video)
        else
          res.status 401 # unauthorized
          res.send()
    else
      res.status 406 # not acceptable
      res.send()





  app.put '/videos/:video_id/finish', (req, res) ->
    accepted = req.get('Accept')
    if accepted == 'application/json'
      User.authenticate req, (currentUser) ->
        if currentUser
          Video.finish req.params.video_id, (output) ->
            res.status 202
            res.json(output)
        else
          res.status 401 # unauthorized
          res.send()
    else
      res.status 406 # not acceptable
      res.send()




module.exports = routes
