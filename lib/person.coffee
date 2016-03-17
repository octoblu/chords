_              = require 'lodash'
{EventEmitter} = require 'events'

class Person extends EventEmitter
  constructor: ({@name, @signal, @minAmplitude}) ->
    @state = 'out'
    @buffer = []
    @emitEnter = _.debounce @emitEnter, 50, leading: true, trailing: false
    @emitExit  = _.debounce @emitExit,  50, leading: true, trailing: false

  amplitude: =>
    _.sum(@buffer) / _.size(@buffer)

  emitEnter: =>
    @state = 'in'
    @emit 'enter', @toJSON()
    @emit 'change', @toJSON()

  emitExit: =>
    @state = 'out'
    @emit 'exit', @toJSON()
    @emit 'change', @toJSON()

  toJSON: =>
    amplitude = @amplitude()

    {@name, @signal, @minAmplitude, @state, amplitude}

  updateAmplitude: (amplitude) =>
    @buffer.unshift amplitude
    @buffer.length = 10

    if @amplitude() > @minAmplitude
      @emitEnter()
    else
      @emitExit()


module.exports = Person
