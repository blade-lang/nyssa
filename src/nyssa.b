import args

# import commands...
import .commands.compile
import .commands.init
import .commands.install
import .commands.restore
import .commands.test
import .commands.uninstall
import .commands.update
import .commands.upgrade

# Import options...
import .options.version

var parser = args.Parser('nyssa')

var commands = {
  compile: compile,
  init: init,
  install: install,
  restore: restore,
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

def nyssa() {
  var opts = parser.parse()

  if opts.options or opts.command {
    var command = opts.command
    opts = opts.options

    if command {
      commands[command.name].run(command.value, opts)
    } else if opts {
      var key = opts.keys()[0]
      options[key].get(opts[key])
    }
  }
}
