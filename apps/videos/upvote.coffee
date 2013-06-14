User = require '../../models/user'
Video = require '../../models/video'

routes = (app) ->
  app.post '/vote', (req, res) ->
    accepted = req.get('Accept')
    if accepted == 'application/json'
      youtubeId = req.body.youtube_video_id
      User.authenticate req, (currentUser) ->
        if currentUser
          Video.find {}, (err, vids) ->
          Video.findOne
            'video_metadata.video_id': youtubeId
            played: false
            (err, vid) ->
              throw err if err
              if vid
                vid.vote currentUser._id
                vid.save (err) ->
                  throw err if err
                  res.status 200
                  res.send()
              else
                res.status 422
                res.send()
        else
          res.status 401 # unauthorized
          res.send()
    else
      res.status 406 # not acceptable
      res.send()

module.exports = routes
