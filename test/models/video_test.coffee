describe 'Video', ->

  user = null

  before (done) ->
    User.register
      ip: '127.0.0.1'
      (u) ->
        user = u
        done()

  after (done) ->
      User.remove done

  describe 'submitting', ->

    video = null

    before (done) ->
      Video.submit
        user_id: user._id
        video_metadata: Fixtures.video.maru
        (v) ->
          video = v
          done()

    after (done) ->
      Video.remove done

    it 'sets the user', ->
      video.user_id.should.equal user._id

    it 'sets the video id', ->
      video.video_metadata.video_id.should.equal '08pVpBq706k'

    it 'sets a posted-at date', ->
      video.submitted_at.should.not.equal undefined

    it 'sets started-at to null', ->
      assert.equal video.started_at, null

    it 'sets finished-at to null', ->
      assert.equal video.finished_at, null

    it 'sets its vote count to 1', ->
      video.vote_count.should.equal 1

    it 'knows the creator voted', ->
      video.votes.indexOf(user._id).should.not.equal -1

    it 'generates an id', ->
      video._id.should.not.equal null


    describe 'and a duplicate', ->
      duplicateVideo = null

      before (done) ->
        Video.submit
          user_id: user._id
          video_metadata: Fixtures.video.maru
          (v) ->
            duplicateVideo = v
            done()

      it 'should return null', ->
        assert.equal duplicateVideo, null

  describe 'vote', ->
    newUser = null
    video = null

    before (done) ->
      Video.submit
        user_id: user._id
        video_metadata: Fixtures.video.maru
        (v) ->
          video = v
          User.register
            ip: '0.0.0.0'
            (u) ->
              newUser= u
              video.vote newUser._id
              video.save done

    after (done) ->
      newUser.remove (err) ->
        throw err if err
        video.remove done

    it 'should increment the vote count', ->
      video.vote_count.should.equal 2

    it 'should know i voted', ->
      video.votes.indexOf(newUser._id).should.not.equal -1

    describe 'voting twice', ->

      before (done) ->
        video.vote newUser._id
        video.save done

      it 'should decrement the vote count', ->
        video.vote_count.should.equal 1

      it 'should remove me from the voted list', ->
        video.votes.indexOf(newUser._id).should.equal -1
      
      describe 'triple voting', ->

        before (done) ->
          video.vote newUser._id
          video.save done

        it 'should count my vote again', ->
          video.vote_count.should.equal 2
          video.votes.indexOf(newUser._id).should.not.equal -1


