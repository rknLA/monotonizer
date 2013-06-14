global.chai = require 'chai'
global.assert = chai.assert
chai.should() # use .should

global.rest = require 'restler'
global.app = require '../server'

global.User = require '../models/user'
global.Video = require '../models/video'

global.Fixtures =
  video: require './fixtures/videos'

mongoose = require 'mongoose'
global.testDB = mongoose.createConnection 'http://localhost/cinema_test'

