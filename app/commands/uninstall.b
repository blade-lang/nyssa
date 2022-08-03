import args

def parse(parser) {
  parser.add_command(
    'uninstall', 
    'Uninstalls a Blade package', 
    {
      type: args.STRING,
    }
  ).add_option(
    'global', 
    'package is a global package', 
    {
      short_name: 'g',
    }
  )
}

def run(value, options, success, error) {
  
}
