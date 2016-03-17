cliClear    = require 'cli-clear'
cson        = require 'cson'
_           = require 'lodash'
PEOPLE_JSON = cson.parseCSONFile './people.cson'
Detector    = require './lib/detector'

class Command
  constructor: ->

  run: =>
    @detector = new Detector people: PEOPLE_JSON

    @detector.on 'enter', @printState
    @detector.on 'exit', @printState

    @detector.detect()

  printState: =>
    cliClear()

    _.each @detector.toJSON(), ({name, state}) =>
      console.log "#{name} is #{state}"


command = new Command
command.run()
