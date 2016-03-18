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
    @stopUntil = Date.now()


  getAudio: (time) =>
    return 0 unless @playing
    return 0 unless Date.now() > @stopUntil

    @writing = (Date.now() - @beganWriting) < @bitperMs

    @writeNext() unless @writing
    return Math.sin( time  * @currentHz)

  writeNext: =>
    @currentHz = @zeroHz
    return @nextChar() if _.isEmpty @charBits
    bit = @charBits.shift()
    @currentHz = @oneHz if bit == 1
    @beganWriting = Date.now()

  nextChar: =>
    @currentHz = @zeroHz

    if _.isEmpty @buffer
      console.log "no characters left. shutting down."
      @playing = false
      return

    nextChar = @buffer.pop()
    @charBits = nextChar.toString(2).split('').map Number
    console.log "nextChar is: #{@charBits}"
    console.log "waiting a bit to play again. #{@bitperMs}"

    @stopUntil = Date.now() + @bitperMs

  start: =>
    return if @bstarted
    @bstarted = true
    @b.play()

  play: =>
    @playing = true

  pause: =>
    @playing = false


  write: (str) =>
    @start()
    @playing = true

    buffer = new Buffer str
    _.each buffer, (byte) =>
      @buffer.push byte

    console.log "write", buffer
    @charBits = []




module.exports = SoundEmitter
