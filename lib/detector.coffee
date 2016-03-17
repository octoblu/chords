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
      person.on 'change', (data) =>
        @emit 'change', data

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

module.exports = Detector
