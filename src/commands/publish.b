import args

def parse(parser) {
  parser.add_command(
    'publish', 
    'Publishes a repository'
  ).add_option(
    'repo', 
    'url to a private repository', 
    {
      short_name: 'r',
      type: args.OPTIONAL,
    }
  ).add_option(
    'version',
    'version number to be published',
    {
      short_name: 'v',
      type: args.STRING,
    }
  )
}

def run(value, options, success, error) {
  
}
