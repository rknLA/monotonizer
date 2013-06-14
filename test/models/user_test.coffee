describe 'User', ->

  user = null

  before (done) ->
    User.register
      ip: '127.0.0.1'
      (u) ->
        user = u
        done()

  after (done) ->
    User.remove done


  describe 'create', ->

    it 'generates a UUID', ->
      assert.notEqual user.id, null

    it 'saves the users ip', ->
      assert.equal user.ip, '127.0.0.1'

  describe 'authenticate with a valid user', ->

    authenticatedUser = null
    mockReq = null

    before (done) ->
      mockReq =
        body:
          user_id: user.id
        misc: 'a misc field to be logged'
      User.authenticate mockReq, (authenticated) ->
        authenticatedUser = authenticated
        done()

    it 'returns a user with the appropriate id', ->
      assert.notEqual authenticatedUser, null
      authenticatedUser.ip.should.equal '127.0.0.1'

    it 'logs the request', (done) ->
      User.findById authenticatedUser.id, (err, theUser) ->
        mostRecentLogItem = theUser.log
        assert Array.isArray(mostRecentLogItem), 'log should be an array'

        assert.equal mostRecentLogItem[0].body.user_id, user.id
        done()


  describe 'authenticate with invalid user', ->
    it 'returns null', (done) ->
      mockReq =
        body:
          user_id: 'foobarbaz'
      User.authenticate mockReq, (authenticated_user) ->
        assert.equal authenticated_user, null
        done()

