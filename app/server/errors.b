import http.status
import json
import .template
import ..log

def _error(s, req, res) {
  res.status = s
  res.headers['Content-Type'] = 'text/plain'
  res.write('${s} - ${status.map[s]}')
}

def not_found(req, res) {
  res.write(template('404', {
    show_login: !res.session.contains('user')
  }))
}

def server_error(err, req, res) {
  res.body = bytes(0)
  _error(500, req, res)

  var error = 'Error: ${err.message}\nTrace:\n${err.stacktrace}'

  log.error(error)
}
