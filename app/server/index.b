import http
import .handler

def server(host, port) {
  
  var server = http.server(port, host)
  server.on_receive(handler)
  server.on_error(|err, _| {
    echo err.message
    echo err.stacktrace
  })

  var host_name = host == '0.0.0.0' ? 'localhost' : host
  echo 'Nyssa repository server started on http://${host_name}:${port}'
  server.listen()
}
