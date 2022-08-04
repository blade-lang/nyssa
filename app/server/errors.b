import http.status
import ..log

def _error(s, req, res) {
  res.status = s
  res.headers['Content-Type'] = 'text/plain'
  res.write('${s} - ${status.map[s]}')
}

def not_found(req, res) {
  _error(404, req, res)
}

def server_error(err, req, res) {
  res.body = ''
  _error(500, req, res)

  var error = 'Error: ${err.message}\nTrace:\n${err.stacktrace}'

  res.write('\n')
  res.write('\n${error}')

  log.error(error)
}
