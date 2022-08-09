import args

def parse(parser) {
  parser.add_command(
    'install', 
    'Installs a Blade package', 
    {
      type: args.STRING,
    }
  ).add_option(
    'global', 
    'installs the package globally', 
    {
      short_name: 'g',
    }
  ).add_option(
    'local', 
    'runs the installation from a local repo', 
    {
      short_name: 'l',
    }
  ).add_option(
    'repo', 
    'the repository to install from', 
    {
      short_name: 'r',
      type: args.OPTIONAL
    }
  )
}

def run(value, options, success, error) {
  
}
