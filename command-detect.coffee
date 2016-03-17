cliClear    = require 'cli-clear'
cson        = require 'cson'
_           = require 'lodash'
PEOPLE_JSON = cson.parseCSONFile './people.cson'
Detector    = require './lib/detector'

class CommandDetect
  run: =>
    @detector = new Detector people: PEOPLE_JSON
    @detector.on 'frame', @printState
    @detector.detect()

  printState: =>
    cliClear()

    _.each @detector.toJSON(), ({name, state, amplitude}) =>
      console.log "#{_.padStart name, 10} is #{_.padEnd state, 4}: #{amplitude}"

command = new CommandDetect
command.run()
