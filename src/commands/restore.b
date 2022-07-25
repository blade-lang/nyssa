import args

def parse(parser) {
  parser.add_command(
    'restore', 
    'Restores all dependencies for a project'
  ).add_option(
    'sources', 
    'extra sources for packages', 
    {
      short_name: 's'
    }
  )
}

def run(value, options) {
  
}
