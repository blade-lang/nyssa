import args

var args_parser = args.Parser('nyssa')

# Commands...
args_parser.add_command(
  'init', 
  'Creates a new package in current directory'
).add_option(
  'name', 
  'The name of the package', 
  {
    short_name: 'n'
  }
)

args_parser.add_command(
  'install', 
  'Installs a Blade package', 
  {
    type: args.STRING
  }
).add_option(
  'global', 
  'Installs the package globally', 
  {
    short_name: 'g'
  }
).add_option(
  'local', 
  'Runs the installation from a local repo', 
  {
    short_name: 'l'
  }
)

args_parser.add_command(
  'test', 
  'Runs tests in the current project'
)

args_parser.add_command(
  'compile', 
  'Compiles the project C extension'
)

args_parser.add_command(
  'uninstall', 
  'Uninstalls a Blade package', 
  {
    type: args.STRING
  }
).add_option(
  'global', 
  'Package is a global package', 
  {
    short_name: 'g'
  }
)

# Options...
args_parser.add_option(
  'version', 
  'Show Nyssa version', 
  {
    short_name: 'v'
  }
)

# Exporting module constructor...
def parser() {
    return args_parser.parse()
}
