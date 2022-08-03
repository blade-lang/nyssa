import ..setup

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
  echo setup.NYSSA_VERSION
}
