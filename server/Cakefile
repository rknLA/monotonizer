
{exec} = require 'child_process'

REPORTER = 'spec'

task 'test', 'run tests', ->
  exec "./test/pre_test && NODE_ENV=test
    PORT=3001
    ./node_modules/.bin/mocha
    --compilers coffee:coffee-script
    --reporter #{REPORTER}
    --require coffee-script
    --require test/test_helper.coffee
    --colors
    test/apps/*.coffee
    test/models/*.coffee
  ", (err, output) ->
    console.log output
    throw err if err
