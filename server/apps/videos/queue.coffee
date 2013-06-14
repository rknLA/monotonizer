User = require '../../models/user'
Video = require '../../models/video'

routes = (app) ->
  app.get '/videos', (req, res) ->
    accepted = req.get('Accept')
    if accepted == 'application/json'
      User.authenticate req, (currentUser) ->
        if currentUser
          Video.unplayedQueue {}, (videos) ->
            if videos
              output =
                offset: 0
                total_video_count: videos.length
                video_count: videos.length
                videos: videos
              res.status 200
              res.send output
            else
              res.status 422
              res.send()
        else
          res.status 401 # unauthorized
          res.send()
    else
      res.status(406) # not acceptable
      res.send()

module.exports = routes
