_              = require 'lodash'
{EventEmitter} = require 'events'

class Person extends EventEmitter
  constructor: ({@name, @signal, @minAmplitude}) ->
    @state = 'out'
    @buffer = []
    @emitEnter = _.debounce @emitEnter, 50, leading: true, trailing: false
    @emitExit  = _.debounce @emitExit,  50, leading: true, trailing: false

  emitEnter: =>
    @state = 'in'
    @emit 'enter', @toJSON()
    @emit 'change', @toJSON()

  emitExit: =>
    @state = 'out'
    @emit 'exit', @toJSON()
    @emit 'change', @toJSON()

  toJSON: => {@name, @signal, @minAmplitude, @state}

  updateAmplitude: (amplitude) =>
    @buffer.unshift amplitude
    @buffer.length = 10

    average = _.sum(@buffer) / _.size(@buffer)

    if average > @minAmplitude
      @emitEnter()
    else
      @emitExit()


module.exports = Person
