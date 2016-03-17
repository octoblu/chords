_ = require 'lodash'
mic = require '@octoblu/microphone'
{DSP,FFT,Float32Array} = require './lib/dsp'

class Command
  constructor: ->
    frameBufferSize = 2* 8192
    @bufferSize = frameBufferSize/2
    @fft = new FFT @bufferSize, 44100

  run: =>
    signal = new Float32Array @bufferSize
    peak = new Float32Array @bufferSize

    mic.startCapture()
    mic.audioStream.on 'data', (data) =>
      signal = new Uint32Array data
      @fft.forward signal

      _.times @bufferSize, (i) =>
        @fft.spectrum[i] *= @doMath(i)

      @displayDrBrownIn @fft.spectrum
      @displayDrWhoIn @fft.spectrum

  displayDrBrownIn: (spectrum) =>
    if @fft.spectrum[3640] > 235812
      console.log "Dr. Brown is in"
    else
      console.log "Dr. Brown is out"

  displayDrWhoIn: (spectrum) =>
    if @fft.spectrum[4086] > 2100000
      console.log "Dr. Who is in"
    else
      console.log "Dr. Who is out"


  doMath: (i) =>
    theLog = Math.log((@fft.bufferSize / 2 - i) * (0.5 / @fft.bufferSize / 2))
    -1 * theLog * @fft.bufferSize


command = new Command
command.run()
