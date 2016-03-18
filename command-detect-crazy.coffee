cliClear    = require 'cli-clear'
cson        = require 'cson'
_           = require 'lodash'
CRAZY_PEOPLE_JSON = cson.parseCSONFile './crazy-people.cson'
Detector    = require './lib/detector'


values = {
  0: 3727
  1: 3690
}

THRESHOLD=300000
BAUD_RATE = 10

class CommandDetect
  run: =>
    @bitPerMs = 1000 / BAUD_RATE
    @count = 0
    @inCharacter = false

    @detector = new Detector people: CRAZY_PEOPLE_JSON
    @detector.on 'frame', @printState
    @detector.detect()
    @charBits = []
    @lastTime = 0
    @ones = []
    @zeroes = []
    @signals = []
    @bits = []
    @characters = []
    @lastTime = Date.now()
    @lastPrintTime = Date.now()
    @bitTime = 0

  printState: (spectrum) =>
    sawOne = 0
    sawZero = 0

    sawOne = 1 if spectrum[values[1]] > THRESHOLD
    sawZero = 1 if spectrum[values[0]] > THRESHOLD

    if sawOne || sawZero
      @signals.push 1
    else
      @signals.push 0

    @ones.push sawOne
    @zeroes.push sawZero

    @signals.shift() if @signals.length > 3

    @printStats() if (Date.now() - @lastPrintTime) > 500

    return @getCharacter() if _.sum(@signals) == 0

    if (Date.now() - @lastTime) > @bitPerMs
      @lastTime = Date.now()
      @signals = []
      @getBit()

  printStats: =>
    cliClear()
    signal = _.mean @signals
    console.log "date: #{Date.now()} time: #{Date.now() - @lastTime}, count: #{++@count}"
    console.log "signal: #{signal}, count: #{@signals.length}"
    console.log "bits:", @bits
    console.log "characters:", @characters
    @lastPrintTime = Date.now()

  resetCharacter: =>
    @resetBit()
    @bits = []
    @lastTime = Date.now()
    @signals = []

  resetBit: =>
    @ones = []
    @zeroes = []
    @reading = false

  getBit: =>
    console.log "get:", @ones, @zeroes
    avgOnes = _.mean @ones
    avgZeroes = _.mean @zeroes
    console.log "Ones: #{avgOnes}", @ones.length
    console.log "Zeroes: #{avgZeroes}" , @zeroes.length

    return @resetBit() unless @ones.length + @zeroes.length > 8
    if avgOnes > 0.95
      @bits.push 1

    if avgZeroes > 0.95
      @bits.push 0

    @resetBit()

    # _.each @detector.toJSON(), ({name, state, amplitude, value}) =>
    #   console.log "#{_.padStart name, 10} is #{_.padEnd state, 4}: #{amplitude}"

  getCharacter: =>
    return @resetCharacter() unless @bits.length > 16
    console.log "I have too many bits! #{@bits.length / 8} per bit."
    chunked = _.chunk @bits, Math.floor(@bits.length / 8)
    console.log "CHUNKS", chunked
    reduced = _.map chunked, (chunk) => _.reduce chunk, _.median

    character = reduced.join('')
    @characters.push character
    @resetCharacter()

command = new CommandDetect
command.run()


#10000 = 3727
#11000 = 3690
