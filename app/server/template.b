import os
import ..setup
import ..log

var templates_directory = os.join_paths(os.args[1], setup.TEMPLATES_DIR)

# create templates directory if missing.
if !os.dir_exists(templates_directory) {
  log.debug('Templates directory missing. Creating...')
  os.create_dir(templates_directory)
}

def template(name, variables) {
  if !is_string(name)
    die Exception('template name expected')

  var path = os.join_paths(templates_directory, name)
  if !path.ends_with('.html') path += '.html'

  if variables != nil and !is_dict(variables)
    die Exception('variables must be passed to templates as a dictionary')
  if variables == nil variables = {}

  var template_file = file(path)
  if template_file.exists() {
    log.debug('Template "${name}" found.')

    var content = template_file.read()

    # replace variables
    for key, value in variables {
      if !key.match('/[a-zA-Z_][a-zA-Z0-9_]*/')
        die Exception('invalid variable passed to template')

      content = content.replace('~((?<![{])[{])${key}\\}~', value).
                        replace('~\\{\\{~', '{')
    }

    log.debug('Template "${name}" loaded.')

    return content
  }

  die Exception('template ${name} not found')
}
