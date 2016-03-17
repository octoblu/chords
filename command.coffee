commander    = require 'commander'
PACKAGE_JSON = require './package.json'

class Command
  run: =>
    commander
      .version PACKAGE_JSON.version
      .command 'calibrate', 'Prints the dominant signal'
      .command 'detect', 'Detect when people enter or exit'
      .parse process.argv

    unless commander.runningCommand
      commander.outputHelp()
      process.exit 1

command = new Command
command.run()
