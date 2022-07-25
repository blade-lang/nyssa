import args
import os

def parse(parser) {
  parser.add_command(
    'init', 
    'Creates a new package in current directory'
  ).add_option(
    'name', 
    'the name of the package', 
    {
      short_name: 'n',
      type: args.OPTIONAL,
    }
  )
}

def run(value, options) {
  echo os.cwd()
}
