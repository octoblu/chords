_        = require 'lodash'
Detector = require './lib/detector'

class CommandCalibrate
  run: =>
    @detector = new Detector people: []
    @detector.detect()
    @detector.on 'frame', @printMax

  printMax: (frame) =>
    max = {amplitude: 0, i: 0}
    _.each frame, (amplitude, i) =>
      return if i < 100
      if max.amplitude < amplitude
        max.amplitude = amplitude
        max.i = i

    console.log _.padStart(max.i, 8), max.amplitude

command = new CommandCalibrate()
command.run()
