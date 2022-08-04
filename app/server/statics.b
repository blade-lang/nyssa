import os
import mime

import .errors
import ..setup


var nyssa_dir = os.args[1]
var static_files_directory = os.join_paths(nyssa_dir, setup.STATIC_DIR)

# if static files directory does not exist, create it.
if !os.dir_exists(static_files_directory)
  os.create_dir(static_files_directory)

def handler(req, res) {
  var static_path = req.path.replace('/^\\/static\\//', '')

  var reader = file(os.join_paths(static_files_directory, static_path))
  
  if reader.exists() {
    res.headers['Content-Type'] = mime.detect_from_name(static_path)
    res.write(reader.read())
  } else {
    errors.not_found(req, res)
  }
}
