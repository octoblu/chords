mic = require '@octoblu/microphone'

class Command
  run: =>
    mic.startCapture()
    mic.audioStream.on 'data', (data) =>
      # console.log data
      process.stdout.write data


command = new Command
command.run()
