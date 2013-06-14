mongoose = require 'mongoose'

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
  input_checksum: String
  user_description: String
  output_file_name: String
  output_file_path: String
  stream_url: String

TrackProcessor = mongoose.model('TrackProcessor', TrackProcessorSchema)

module.exports = mongoose.model('TrackProcessor')
