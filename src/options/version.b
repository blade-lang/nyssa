import ..constants

def parse(parser) {
  parser.add_option(
    'version', 
    'Show Nyssa version', 
    {
      short_name: 'v'
    }
  )
}

def get(value) {
  echo constants.NYSSA_VERSION
}
