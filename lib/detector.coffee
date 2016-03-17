{EventEmitter}         = require 'events'
_                      = require 'lodash'
mic                    = require '@octoblu/microphone'
{DSP,FFT,Float32Array} = require './dsp'
Person                 = require './person'

class Detector extends EventEmitter
  constructor: ({people}) ->
    @people = _.map people, (data) => new Person data

    @bufferSize = 8192
    @fft = new FFT @bufferSize, 44100

    _.each @people, (person) =>
      person.on 'enter', (data) => @emit 'enter', data
      person.on 'exit', (data) => @emit 'exit', data

  detect: =>
    mic.startCapture()
    mic.audioStream.on 'data', @onData

  doMath: (i) =>
    theLog = Math.log((@fft.bufferSize / 2 - i) * (0.5 / @fft.bufferSize / 2))
    -1 * theLog * @fft.bufferSize

  onData: (data) =>
    @fft.forward new Uint32Array data

    _.times @bufferSize, (i) =>
      @fft.spectrum[i] *= @doMath(i)

    @processFrame()

  processFrame: =>
    _.each @people, (person) =>
      person.updateAmplitude @fft.spectrum[person.signal]

  toJSON: =>
    _.map @people, (person) => person.toJSON()
  #   @displayDrBrownIn @fft.spectrum
  #   @displayDrWhoIn @fft.spectrum
  #
  # displayDrBrownIn: (spectrum) =>
  #   if @fft.spectrum[3640] > 235812
  #     console.log "Dr. Brown is in"
  #   else
  #     console.log "Dr. Brown is out"
  #
  # displayDrWhoIn: (spectrum) =>
  #   if @fft.spectrum[4086] > 2100000
  #     console.log "Dr. Who is in"
  #   else
  #     console.log "Dr. Who is out"

module.exports = Detector
