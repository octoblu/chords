baudio = require 'baudio'
_ = require 'lodash'

class SoundEmitter
  constructor: ({baudRate, @channelHz, @channelWidth}) ->
    @bitperMs  = 1000 / baudRate
    @b         = baudio @getAudio
    @currentHz = @channelHz
    @zeroHz    = @channelHz
    @oneHz     = @channelHz + @channelWidth
    @buffer    = []
    @charBits  = []
    @beganWriting = Date.now()

  getAudio: (time) =>
    return 0 unless @playing
    @writing = (Date.now() - @beganWriting) < @bitperMs
    @writeNext() unless @writing
    return Math.sin( time  * @currentHz)

  writeNext: =>
    @beganWriting = Date.now()
    return @nextChar() if _.isEmpty @charBits
    bit = @charBits.pop()
    console.log bit
    if bit == 1
      @currentHz = @oneHz
    else
      @currentHz = @zeroHz

    @beganWriting = Date.now()

  nextChar: =>
    @currentHz = @zeroHz

    return if _.isEmpty @buffer
    nextChar = @buffer.pop()
    console.log "nextChar is: #{nextChar}"
    @charBits = nextChar.toString(2).split('').map Number
    console.log @charBits
    @writeNext()

  start: =>
    @b.play()

  play: =>
    @playing = true

  pause: =>
    @playing = false


  write: (str) =>
    buffer = new Buffer str
    _.each buffer, (byte) =>
      @buffer.push byte

    console.log "write", buffer
    @charBits = []




module.exports = SoundEmitter
