import ..log
import .errors
import .routes { routes }

def _log_request(req, res) {
  log.info('RepositoryAccess: ${req.ip} - "${req.method} ${req.request_uri} ' +
      '${req.http_version}" ${res.status} ${res.status < 400 ? res.body.length() : '-'}')
}

def _get_uri_route_data(route, path) {
  var result = {}

  var name_pattern = '([a-zA-Z_][a-zA-Z0-9_]+)'
  var regex = route.
    # * in routes match anything or nothing after.
    replace('/[*]/', '(.*?)').
    # + in routes match something after.
    replace('/[+]/', '(.+)').
    # convert {id} pattern to matching ids for path
    replace('/\\{${name_pattern}\\}/', '(?P<$1>[^/]+)')

  var matches = path.matches('~^${regex}$~i')
  if matches {
    for k, v in matches {
      if is_string(k) {
        result[k] = v[0]
      }
    }
  }

  return result
}

def router(req, res) {
  try {
    var view = errors.not_found

    # Check exact matchs first...
    if routes.contains(req.path) {
      view = routes[req.path]
    } else {
      for route, fn in routes {
        var route_data = _get_uri_route_data(route, req.path)
        if route_data {
          view = fn
          req.params = route_data
        }
      }
    }

    view(req, res)
  } catch Exception e {
    errors.server_error(e, req, res)
  }

  # Log every request before exiting the client session.
  _log_request(req, res)
}
