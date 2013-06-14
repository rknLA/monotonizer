querystring = require 'querystring'
rest = require 'restler'
mongoose = require 'mongoose'
async = require 'async'

Video = require './video'

SearchSchema = new mongoose.Schema
  user:
    type: mongoose.Schema.Types.ObjectId
    required: true
  query:
    type: String
    required: true
  videos:
    type: Array
    required: true
  pageSize:
    type: Number
    required: true
    default: 20
  

consolidateVideoMetadata = (googleMetadata) ->
  consolidatedMetadata =
    title: googleMetadata.title.$t
    description: googleMetadata.media$group.media$description.$t
    author: googleMetadata.media$group.media$credit[0].yt$display
    thumbnail: googleMetadata.media$group.media$thumbnail
    video_id: googleMetadata.media$group.yt$videoid.$t

mergeSearchVideoWithDbVideo = (item, callback) ->
  consolidated = consolidateVideoMetadata item
  Video.findOne
    'video_metadata.video_id': consolidated.video_id
    played: false
    (err, vid) ->
      searchResult =
        video_metadata: consolidated
        submission_id: if vid then vid.id else null
        vote_count: if vid then vid.vote_count else null
        votes: if vid then vid.votes else []
      callback null, searchResult


consolidateYouTubeResults = (jsonInput, callback) ->
  output = []
  async.map jsonInput.feed.entry, mergeSearchVideoWithDbVideo, (err, results) ->
    throw err if err
    callback results

SearchSchema.static 'createWithQuery', (attrs, callback) ->
  search = new this()
  search.user = attrs.user_id
  search.query = attrs.q
  search.pageSize = 20

  query =
    q: attrs.q
    'max-results': 20
    v: 2
    alt: 'json'
  queryStr = querystring.stringify query
  rest.get("https://gdata.youtube.com/feeds/api/videos?#{queryStr}", {
    headers:
      'X-GData-Key': "key=#{attrs.googleApiKey}"
  }).on 'complete', (data, response) ->
    consolidateYouTubeResults data, (consolidated) ->
      search.videos = consolidated
      search.save (e, doc) ->
        throw e if e
        callback doc


SearchSchema.static 'page', (search_id, page_number, callback) ->
  callback

Search = mongoose.model('Search', SearchSchema)

module.exports = mongoose.model('Search')
