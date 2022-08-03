import args
import os
import ..server

def parse(parser) {
  parser.add_command(
    'serve', 
    'Starts a local Nyssa repository server'
  ).add_option(
    'port', 
    'port of the server (default: 3000)', 
    {
      short_name: 'p',
      type: args.OPTIONAL,
    }
  ).add_option(
    'host',
    'the host ip (default: 127.0.0.1)',
    {
      short_name: 'n',
      type: args.OPTIONAL,
    }
  )
}

def run(value, options, success, error) {
  var port = to_number(options.get('port', 3000))
  var host = options.get('host', '127.0.0.1')
  server(host, port)
}
