SoundEmitter = require './sound-emitter.coffee'

emitter = new SoundEmitter baudRate: 10, channelHz: 100000, channelWidth: 10000

module.exports = emitter
