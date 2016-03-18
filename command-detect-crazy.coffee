cliClear    = require 'cli-clear'
cson        = require 'cson'
_           = require 'lodash'
CRAZY_PEOPLE_JSON = cson.parseCSONFile './crazy-people.cson'
Detector    = require './lib/detector'

class CommandDetect
  run: =>
    @detector = new Detector people: CRAZY_PEOPLE_JSON
    @detector.on 'frame', @printState
    @detector.detect()

  printState: (spectrum)=>
    cliClear()

    _.each @detector.toJSON(), ({name, state, amplitude}) =>
      console.log "#{_.padStart name, 10} is #{_.padEnd state, 4}: #{amplitude}"

    maxVal = 1000
    maxIndex = 0
    _.each spectrum, (value, index) =>
      return true unless value > 600000 and index > 500 and index < 4000
      maxVal = value if value > maxVal
      maxIndex = index if index > maxIndex

    console.log {maxVal, maxIndex}

command = new CommandDetect
command.run()


#10000 = 3727
#11000 = 3690
