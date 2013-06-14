async = require 'async'

describe 'The Queue', ->

  user1 = null
  user2 = null
  user3 = null

  video1 = null
  video2 = null
  video3 = null
  playedVideo = null

  before (done) ->
    async.series [
      (callback) ->
        User.register
          ip: '127.0.0.1'
          (u) ->
            user1 = u
            callback()
    ,
      (callback) ->
        User.register
          ip: '127.0.0.2'
          (u) ->
            user2 = u
            callback()
    ,
      (callback) ->
        User.register
          ip: '127.0.0.3'
          (u) ->
            user3 = u
            callback()
    ,
      (callback) ->
        Video.submit
          user_id: user1._id
          video_metadata: Fixtures.video.endOfWorld
          (v) ->
            video1 = v
            callback()
    ,
      (callback) ->
        Video.submit
          user_id: user1._id
          video_metadata: Fixtures.video.dogDreams
          (v) ->
            video2 = v
            callback()
    ,
      (callback) ->
        Video.submit
          user_id: user1._id
          video_metadata: Fixtures.video.stewart
          (v) ->
            video3 = v
            callback()
    ],
    (err, callback) ->
      video1.vote user2._id
      video1.save (err, vid) ->
        video1 = vid
        video2.vote user2._id
        video2.vote user3._id
        video2.save (err, vid) ->
          video2 = vid
          done()

  describe 'getting all unplayed videos', ->
    queueResults = null
    queueResponse = null

    before (done) ->
      rest.get("http://localhost:#{app.settings.port}/videos?user_id=#{user3._id}",
        headers:
          'Accept': 'application/json'
      ).on 'complete', (data, response) ->
        queueResults = data
        queueResponse = response
        done()

    it 'should respond with OK', ->
      queueResponse.statusCode.should.equal 200

    it 'should contain the total number of unplayed videos in the queue', ->
      assert 'total_video_count' of queueResults
      queueResults.total_video_count.should.equal 3

    it 'should contain the number of unplayed videos in this response', ->
      assert 'video_count' of queueResults
      queueResults.video_count.should.equal 3

    it 'should contain the queue starting index', ->
      assert 'offset' of queueResults
      queueResults.offset.should.equal 0

    it 'should contain submitted videos in order of rank', ->
      assert 'videos' of queueResults
      queueResults.videos[0].video_metadata.video_id.should.equal Fixtures.video.dogDreams.video_id
      queueResults.videos[1].video_metadata.video_id.should.equal Fixtures.video.endOfWorld.video_id
      queueResults.videos[2].video_metadata.video_id.should.equal Fixtures.video.stewart.video_id


  describe 'with completed videos', ->
    queueWithPlayedResults = null
    queueWithPlayedResponse = null

    before (done) ->
      Video.submit
        user_id: user1._id
        video_metadata: Fixtures.video.badger
        (v) ->
          playedVideo = v
          playedVideo.played = true
          playedVideo.save (err, doc) ->
            throw err if err
            rest.get("http://localhost:#{app.settings.port}/videos?user_id=#{user3._id}",
              headers:
                'Accept': 'application/json'
            ).on 'complete', (data, response) ->
              queueWithPlayedResults = data
              queueWithPlayedResponse = response
              done()

    it 'should only display unplayed videos', ->
      queueWithPlayedResults.videos.length.should.equal 3
      queueWithPlayedResults.videos[0].video_metadata.video_id.should.equal Fixtures.video.dogDreams.video_id
      queueWithPlayedResults.videos[1].video_metadata.video_id.should.equal Fixtures.video.endOfWorld.video_id
      queueWithPlayedResults.videos[2].video_metadata.video_id.should.equal Fixtures.video.stewart.video_id



  describe "The Presenter's role", ->

    describe 'beginning playback', ->
      startingQueue = null
      firstVideo = null
      playResponse = null

      before (done) ->
        rest.get("http://localhost:#{app.settings.port}/videos?user_id=#{user3._id}&limit=4",
          headers:
            'Accept': 'application/json'
        ).on 'complete', (data, response) ->
          startingQueue = data

          firstVideo = startingQueue.videos[0]

          rest.put("http://localhost:#{app.settings.port}/videos/#{firstVideo._id}/play?user_id=#{user3._id}",
            headers:
              'Accept': 'application/json'
          ).on 'complete', (data, response) ->
            playResponse = response
            if response.statusCode == 202
              firstVideo = data
            done()

      it "should respond with accepted", ->
        playResponse.statusCode.should.equal 202

      it "should set the video's started_at", ->
        assert.notEqual firstVideo.started_at, null

      it "should mark the video as playing", ->
        assert firstVideo.playing

      it "should not mark the video as played", ->
        assert !firstVideo.played
      
      it "should not set the video's finished_at", ->
        assert !firstVideo.finished_at

      describe 'finish to start', ->
        initQueue = null
        initFinishResponse = null
        initVideo = null
        formerVideo = null

        before (done) ->
          rest.put("http://localhost:#{app.settings.port}/videos/null/finish?user_id=#{user3._id}",
            headers:
              'Accept': 'application/json'
          ).on 'complete', (data, response) ->
            initFinishResponse = response
            if response.statusCode == 202
              formerVideo = data.finishedVideo
              initVideo = data.nextVideo
              initQueue = data.topThree
            done()

        it 'should not have a former video', ->
          assert !formerVideo

        it 'should give the first video as next', ->
          assert initVideo
          assert initVideo.video_metadata.video_id.should.equal startingQueue.videos[0].video_metadata.video_id

        it 'should provide the top three', ->
          assert initQueue
          assert initQueue[0].video_metadata.video_id.should.equal startingQueue.videos[1].video_metadata.video_id



      describe 'finishing playback', ->

        updatedQueue = null
        finishResponse = null
        nextVideo = null

        before (done) ->
          rest.put("http://localhost:#{app.settings.port}/videos/#{firstVideo._id}/finish?user_id=#{user3._id}",
            headers:
              'Accept': 'application/json'
          ).on 'complete', (data, response) ->
            finishResponse = response
            if response.statusCode == 202
                firstVideo = data.finishedVideo
                nextVideo = data.nextVideo
                updatedQueue = data.topThree
            done()

        it "should respond with accepted", ->
          finishResponse.statusCode.should.equal 202 # accepted

        it "should mark the current video as played", ->
          assert firstVideo.played
          
        it "should set the video's finished_at", ->
          assert.notEqual firstVideo.finished_at, null

        it "should get the latest queue", ->
          assert.notEqual updatedQueue, null
          updatedQueue.length.should.equal 3 # this test fails because there aren't enough mocked videos
          nextVideo.video_metadata.video_id.should.equal startingQueue.videos[1].video_metadata.video_id


