import args
import io
import colors
import os

# import commands...
import .commands.compile
import .commands.init
import .commands.install
import .commands.restore
import .commands.test
import .commands.uninstall
import .commands.update
import .commands.upgrade
import .commands.publish
import .commands.serve

# Import options...
import .options.version

var parser = args.Parser('nyssa')

var commands = {
  compile: compile,
  init: init,
  install: install,
  publish: publish,
  restore: restore,
  serve: serve,
  test: test,
  uninstall: uninstall,
  update: update,
  upgrade: upgrade,
}

var options = {
  version: version,
}

for cmd in commands {
  cmd.parse(parser)
}
for o in options {
  o.parse(parser)
}

def success(msg) {
  io.stderr.write(colors.text(
    colors.text('Success: ${msg}\n', colors.text_color.green),
    colors.style.bold
  ))
  os.exit(0)
}

def error(msg) {
  io.stderr.write(colors.text('error: ${msg}\n', colors.text_color.red))
  os.exit(1)
}

def nyssa() {
  var opts = parser.parse()

  if opts.options or opts.command {
    var command = opts.command
    opts = opts.options

    if command {
      commands[command.name].run(command.value, opts, success, error)
    } else if opts {
      var key = opts.keys()[0]
      options[key].get(opts[key])
    }
  }
}
