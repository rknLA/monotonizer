mongoose = require 'mongoose'
childProcess = require 'child_process'
path = require 'path'
soundcloud = require '../lib/soundcloud'
fs = require 'fs'

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
  soundcloud_token: String
  stream_url: String

TrackProcessorSchema.methods.process = (app_root) ->
  this.status = 'processing'
  this.save (err, track) ->
    if err
      console.log "Error saving track for processing."
    else
      render_root = path.join(app_root, 'public', 'monotonous')
      in_file_path = track.input_file_path
      out_file_name = track.input_hash + '.wav'
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

      dotCounter = 0
      mono.stderr.on 'data', (d) ->
        ++dotCounter
        if dotCounter > 100
          dotCounter = 0
          process.stdout.write('.')
      mono.stdout.on 'data', (d) ->
        console.log ''+d

      mono.on 'close', (code) ->
        console.log 'child process closed with code ' + code
        if code == 0
          # succeeded
          track.status = 'processed'
          track.output_file_name = out_file_name
          track.output_file_path = out_file_path
          track.stream_url = path.join('/', 'monotonous', out_file_name)
          track.save()
          track.uploadToSoundcloud()

TrackProcessorSchema.methods.uploadToSoundcloud = () ->
  self = this
  console.log 'uploading to soundcloud'
  file_path = this.output_file_path
  console.log 'file path: ' + file_path
  if this.status != 'processed' || !this.soundcloud_token
    return
  fs.stat this.output_file_path, (err, info) ->
    if err
      console.log "Error stating file to upload"
      return
    file_size = info.size
    console.log "file is " + file_size + " bytes"
    soundcloud.postTrack file_path, self.description, "public", self.soundcloud_token, (response) ->
      console.log response
      soundcloud.pollTrackStatus response.id, self.soundcloud_token, (err, track) ->
        if err
          self.status = 'soundcloud error'
          self.save()
        else
          self.status = 'posted'
          self.save()


TrackProcessor = mongoose.model('TrackProcessor', TrackProcessorSchema)

module.exports = mongoose.model('TrackProcessor')
