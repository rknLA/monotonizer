mongoose = require 'mongoose'

VideoSchema = new mongoose.Schema
  user_id:
    type: mongoose.Schema.Types.ObjectId
    required: true
  video_metadata:
    video_id:
      type: String
      required: true
      index: true
    author:
      type: String
      required: true
    title:
      type: String
      required: true
    description: String
    thumbnail:
      type: Array
      required: true
  vote_count:
    type: Number
    default: 1
  votes: [mongoose.Schema.Types.ObjectId]
  submitted_at:
    type: Date
    default: Date.now
  started_at: Date
  finished_at: Date
  playing:
    type: Boolean
    default: false
  played:
    type: Boolean
    default: false

VideoSchema.static 'submit', (attrs, callback) ->
  unless attrs.video_metadata
    callback()
    return
  ytID = attrs.video_metadata.video_id
  that = this
  this.findOne
    'video_metadata.video_id': ytID
    played: false
    (err, vid) ->
      if vid
        callback()
      else
        video = new that()
        video.video_metadata = attrs.video_metadata
        video.user_id = attrs.user_id
        video.votes = [attrs.user_id]
        video.vote_count = 1
        video.started_at = null
        video.finished_at = null
        video.save (e, doc) ->
          if e
            throw e
          else
            callback doc
      
VideoSchema.static 'unplayedQueue', (query, callback) ->
  this.find
    played: false
    playing: false
    started_at: null
    finished_at: null
  , null,
    sort:
      vote_count: -1
    limit: if 'limit' of query then query.limit else 20
    skip: if 'offset' of query then query.offset else 0
  , (err, videos) ->
    throw err if err
    callback videos

VideoSchema.methods.vote = (user_id) ->
  # add a vote for users that exist, remove a vote for those that don't
  # basically, behave like a toggle
  vote_index = this.votes.indexOf user_id
  if vote_index is -1
    this.votes.push user_id
    this.vote_count += 1
  else
    this.votes.splice vote_index, 1
    this.vote_count -= 1

VideoSchema.static 'play', (video_id, callback) ->
  console.log "play called on video_id: ", video_id
  this.findById video_id, (err, video) ->
    throw err if err
    video.playing = true
    video.started_at = Date.now()
    video.save callback

VideoSchema.static 'finish', (video_id, callback) ->
  that = this
  console.log "finish called on video_id: ", video_id
  if video_id is null or video_id is 'null'#this is the "start the presenter" hook
    console.log "null vid, yo"
    finishOutput =
      finishedVideo: ''
    that.unplayedQueue {limit: 4}, (queue) ->
      finishOutput.nextVideo = queue[0]
      finishOutput.topThree = queue[1..]
      callback finishOutput
  else
    console.log "video_id is not null, it's #{video_id}"
    this.findById video_id, (err, video) ->
      console.log "error finding video to finish: ", err
      throw err if err
      video.playing = false
      video.played = true
      video.finished_at = Date.now()
      video.save (err, savedVideo) ->
        console.log 'saved finished video error: ', err
        throw err if err
        finishOutput =
          finishedVideo: savedVideo
        that.unplayedQueue {limit: 4}, (queue) ->
          finishOutput.nextVideo = queue[0]
          finishOutput.topThree = queue[1..]
          callback finishOutput

Video = mongoose.model('Video', VideoSchema)
module.exports = mongoose.model('Video')
