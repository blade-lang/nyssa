import ..route { * }

def get_version() {
  return '0.1.0'
}

def run_help(args) {
  if !args {
    echo 'Version: ' + get_version()
    echo 'Usage: nyssa <action> [value]'
    echo ''
    echo 'Actions:'
    echo ''
    for x, y in map {
      if x != 'help' {
        echo '  - ${x}:'.rpad(24) + y.help[0]
      }
    }
    echo '  - help:'.rpad(24) + 'Show this help message.'
  } else if args.length() == 1 {
    var k = args[0]
    if map.contains(k) {
      var commands = map[k].help
      var has_options = commands.keys().length() > 1
      
      echo 'Usage: nyssa ${k} ' + (has_options ? '[options...] ' : nil) + '<name>'
      echo ''
      echo '    ${commands[0]}'
      echo ''
      if has_options {
        echo 'Options:'
        echo ''
        for x, y in commands {
          if x != 0 {
            echo '    ${x}:'.rpad(24) + y
          }
        }
      }
    } else {
      run_help([])
    }
  }
}

map.set('help', run_help)
