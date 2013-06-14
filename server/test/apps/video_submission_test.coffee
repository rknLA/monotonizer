describe 'Videos Endpoint (submission)', ->
  user = null
  video = null

  before (done) ->
    User.register
      ip: '127.0.0.1'
      (u) ->
        user = u
        done()

  after (done) ->
    User.remove done

  describe 'when none exist', ->
    restData = null
    restResponse = null

    before (done) ->
      videoData = Fixtures.video.albini
      rest.postJson("http://localhost:#{app.settings.port}/videos", {
        user_id: user.id
        video_metadata: videoData
      }, {
        headers:
          'Accept': 'application/json'
      }).on 'complete', (data, response) ->
        restData = data
        restResponse = response
        done()

    after (done) ->
      Video.remove done

    it 'should respond with created', ->
      restResponse.should.not.equal undefined
      restResponse.statusCode.should.equal 201

    it 'should have the right user_id', ->
      restData.user_id.should.equal user.id

    it 'should have the right video metadata', ->
      restData.video_metadata.video_id.should.equal 'Y8-CZaHFTdQ'

    it 'should have the right vote count', ->
      restData.vote_count.should.equal 1
      restData.votes.indexOf(user.id).should.not.equal -1

  describe 'when some are in the queue', ->
    existingVideo = null

    before (done) ->
      Video.submit
        user_id: user._id
        video_metadata: Fixtures.video.albini
        (v) ->
          existingVideo = v
          done()

    after (done) ->
      existingVideo.remove done

    describe 'a new video', ->
      restData = null
      restResponse = null

      before (done) ->
        rest.postJson("http://localhost:#{app.settings.port}/videos", {
          user_id: user.id
          video_metadata: Fixtures.video.girlfriend
        }, {
          headers:
            'Accept': 'application/json'
        }).on 'complete', (data, response) ->
          restData = data
          restResponse = response
          done()
      
      it 'should get created like normal', ->
        restResponse.statusCode.should.equal 201

      it 'should set the right user id', ->
        restData.user_id.should.equal user.id
      it 'should have the right video metadata', ->
        restData.video_metadata.video_id.should.equal 'Zg6iMDfOl9E'
      it 'should have the right vote count', ->
        restData.vote_count.should.equal 1
        restData.votes.indexOf(user.id).should.not.equal -1

    describe 'a duplicate video', ->
      duplicateRestData = null
      duplicateRestResponse = null

      before (done) ->
        rest.postJson("http://localhost:#{app.settings.port}/videos", {
          user_id: user.id
          video_metadata: Fixtures.video.albini
        }, {
          headers:
            'Accept': 'application/json'
        }).on 'complete', (data, response) ->
          duplicateRestData = data
          duplicateRestResponse = response
          done()

      it 'should not get created', ->
        duplicateRestResponse.should.not.equal undefined
        duplicateRestResponse.statusCode.should.equal 409 # conflict
        #right now test fails here

      it 'should return the existing video', ->
        duplicateRestData.should.not.equal undefined
        duplicateRestData._id.should.equal existingVideo.id
        duplicateRestData.user_id.should.equal user.id
        duplicateRestData.video_metadata.video_id.should.equal 'Y8-CZaHFTdQ'
        duplicateRestData.vote_count.should.equal 1
        duplicateRestData.votes.indexOf(123).should.equal -1

