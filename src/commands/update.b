import args

def parse(parser) {
  parser.add_command(
    'update', 
    'Updates a package', 
    {
      type: args.STRING
    }
  ).add_option(
    'global', 
    'target is a global package', 
    {
      short_name: 'g'
    }
  )
}

def run(value, options, success, error) {
  
}
