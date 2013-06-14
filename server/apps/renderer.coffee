TrackProcessor = require '../models/track_processor'
fs = require 'fs'
path = require 'path'

routes = (app) ->
  app.post '/track', (req, res) ->
    if req.files && req.files.sourceTrack
      # we have a file
      # check it's type
      track = req.files.sourceTrack
      if track.type.indexOf('audio') == 0
        # it's an audio file!
        fs.readFile track.path, (err, data) ->
          hash = track.path.split('/').slice(-1)[0] # last part of the path
          newPath = path.join(app.get('root'), 'uploads', hash)
          fs.mkdir newPath, (err) ->
            if err
              console.log "error creating directory", err
              res.redirect 500, '/index'
            else
              fullPath = path.join(newPath, track.name)
              fs.writeFile fullPath, data, (err) ->
                if err
                  console.log "Error saving file: ", err
                  res.redirect 500, '/index'
                else
                  new_track = TrackProcessor.create {
                    status: 'uploaded'
                    input_file_path: fullPath
                    input_file_name: track.name
                    input_hash: hash
                    user_description: req.body.description || null
                  }, (err, track) ->
                    if err
                      console.log "Error creating track processor", err
                      res.redirect 500, '/index'
                    else
                      res.redirect 201, '/tracks/' + track.input_hash
    else
      res.redirect 422, '/index'

module.exports = routes
