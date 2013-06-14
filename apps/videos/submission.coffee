User = require '../../models/user'
Video = require '../../models/video'

routes = (app) ->
  app.post '/videos', (req, res) ->
    accepted = req.get('Accept')
    if accepted == 'application/json'
      #make object
      youtubeId = req.body.video_metadata.video_id
      User.authenticate req, (currentUser) ->
        if currentUser
          Video.submit
            user_id: currentUser._id
            video_metadata: req.body.video_metadata
            (v) ->
              if v
                res.status(201)
                res.json(v)
              else
                Video.findOne
                  'video_metadata.video_id': youtubeId
                  (err, vid) ->
                    if err
                      res.status(422) # unprocessable entity
                      res.send(err)
                    else
                      res.status(409) # conflict
                      res.json(vid)
        else
          res.status(401) # unauthorized
          res.send()
    else
      res.status(406) # not acceptable
      res.send()

module.exports = routes
