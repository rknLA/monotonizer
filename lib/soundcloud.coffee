https = require 'https'
qs = require 'querystring'
fs = require 'fs'
rest = require 'restler'
keys = require '../keys'

API_HOST = 'api.soundcloud.com'
OAUTH2_TOKEN_ENDPOINT = '/oauth2/token'
authorizeUrl = 'https://soundcloud.com/connect'

# generic HTTP request wrapper
_request = (options, params, callback) ->
  req = https.request options, (res) ->
    output = ''
    res.setEncoding 'utf8'

    res.on 'data', (chunk) ->
      output += chunk

    res.on 'end', ->
      response = JSON.parse output
      callback response

  req.write params if options.method == 'POST'
  req.end()

# wrap API requests that use an access token
exports.request = (method, path, token, callback) ->
  options = {
    host: API_HOST
    port: 443
    path: "#{path}?oauth_token=#{token}"
    method: 'GET'
    headers:
      'Content-Type': 'application/json'
  }
  _request options, '', (response) ->
    callback response

# Periodically request a track status. Call callback on finish or error.
exports.pollTrackStatus = (trackId, token, callback) ->
  poll = (trackId, token, callback) ->
    exports.request 'GET', "/tracks/#{trackId}.json", token, (response) ->
      return callback(null, response) if response.state == 'finished'
      return callback('Error Uploading Track', null) if response.state == 'failed'
      setTimeout(poll, 2000, trackId, token, callback)
  poll(trackId, token, callback)

# Construct SoundCloud authorization URL
exports.authorizeUrl = ->
  params = qs.stringify
    client_id: keys.soundcloud.client_id
    redirect_uri: keys.soundcloud.redirect_url
    scope: 'non-expiring'
    response_type: 'code'
  "#{authorizeUrl}?#{params}"

# Exchange authorization code for access token
exports.exchangeToken = (code, callback) ->
  params = qs.stringify
    grant_type: 'authorization_code'
    client_id: keys.soundcloud.client_id
    client_secret: keys.soundcloud.client_secret
    code: code
  params += "&redirect_uri=#{keys.soundcloud.redirect_url}"

  responseHandler = (response) ->
    callback response.access_token

  _request
    host: API_HOST
    port: 443
    path: OAUTH2_TOKEN_ENDPOINT
    method: 'POST'
    headers:
      'Content-Type': 'application/x-www-form-urlencoded'
      'Content-Length': params.length
    , params, responseHandler

# Post track
exports.postTrack = (file, title, description, accessToken, callback) ->
  sharing = "public"
  params =
    'track[title]': title
    'track[description]': description
    'track[sharing]': sharing
    'oauth_token': accessToken

  stat = fs.statSync file
  req = rest.post 'https://api.soundcloud.com/me/tracks.json',
    multipart: true
    data:
      'track[title]': title
      'track[sharing]': sharing
      'track[asset_data]': rest.file(file, null, stat.size, null, 'application/octet-stream')
      'oauth_token': accessToken
  req.on 'complete', (data) ->
    callback data
