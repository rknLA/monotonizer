mongoose = require 'mongoose'
childProcess = require 'child_process'
path = require 'path'

TrackProcessorSchema = new mongoose.Schema
  status:
    type: String
    required: true
  input_file_path:
    type: String
    required: true
  input_file_name:
    type: String
    required: true
  input_hash: String
  user_description: String
  output_file_name: String
  output_file_path: String
  stream_url: String

TrackProcessorSchema.methods.process = (app_root) ->
  this.status = 'processing'
  this.save (err, track) ->
    if err
      console.log "Error saving track for processing."
    else
      render_root = path.join(app_root, 'public', 'monotonous')
      in_file_path = track.input_file_path
      out_file_name = track.input_hash + '.flac'
      out_file_path = path.join(render_root, out_file_name)
      console.log 'writing to ' + out_file_path
      mono = childProcess.spawn './lib/monotonize.py', [
        in_file_path,
        out_file_path
      ],
        cwd: app_root

      mono.on 'error', (e) ->
        console.log 'child process failed with error: '
        console.log e.stack

      mono.on 'close', (code) ->
        console.log 'child process closed with code ' + code
        if code == 0
          # succeeded
          track.status = 'completed'
          track.output_file_name = out_file_name
          track.output_file_path = out_file_path
          track.stream_url = path.join('/', 'monotonous', out_file_name)
          track.save()

TrackProcessor = mongoose.model('TrackProcessor', TrackProcessorSchema)

module.exports = mongoose.model('TrackProcessor')
