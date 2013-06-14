TrackProcessor = require '../models/track_processor'

routes = (app) ->
  app.get '/history', (req, res) ->
    TrackProcessor.find {status: 'completed'}, (err, tracks) ->
      if (err)
        res.render 'error', err
      else
        content = {tracks: tracks || []}
        res.render 'history', content

module.exports = routes
