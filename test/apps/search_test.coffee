querystring = require 'querystring'

describe "Video Search Endpoint", ->
  user = null

  before (done) ->
    User.register
      ip: '127.0.0.1'
      (u) ->
        user = u
        done()

  describe 'new complete searches', ->
    # this is only really semi-valid, since testing this relies on youtube.
    searchResults = null
    searchResponse = null

    before (done) ->
      data =
        q: 'maru jumps out of a box'
        user_id: user.id
      dataStr = querystring.stringify data
      rest.get("http://localhost:#{app.settings.port}/search?#{dataStr}",
        headers:
          'Accept': 'application/json'
      ).on 'complete', (data, response) ->
        searchResults = data
        searchResponse = response
        done()

    it 'should respond with created', ->
      searchResponse.statusCode.should.equal 201

    it 'should have a search id', ->
      assert.notEqual searchResults._id, null

    it 'should have an array of video metadata', ->
      searchResults.videos.length.should.equal 20

    describe 'Each video', ->

      it 'should have a submission_id', ->
        assert ('submission_id' of searchResults.videos[0]), "searched videos should have submission_id fields, even if they're null"

      it 'should have a vote count', ->
        assert ('vote_count' of searchResults.videos[0]), "searched videos should have a vote_count, even if it's 0"

      it 'should have a vote list', ->
        assert ('votes' of searchResults.videos[0]), "searched videos should have a vote array, even if it's empty"




