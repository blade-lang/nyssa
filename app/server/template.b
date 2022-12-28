import os
import json
import iters
import cocoa
import drawdown
import ..setup
import ..log
import .util

var templates_directory = os.join_paths(os.args[1], setup.TEMPLATES_DIR)

# create templates directory if missing.
if !os.dir_exists(templates_directory)
  os.create_dir(templates_directory)

var functions = {
  length: | t | {
    return t.length()
  },
  plus_one: | t | {
    return t + 1
  },
  format_number: | t | {
    return util.format_number(t)
  },
  strip_line: | t | {
    return t.replace('\n', '\\n')
  },
  sort_name: | t | {
    return t == 'name'
  },
  sort_download: | t | {
    return t == 'downloads'
  },
  sort_created: | t | {
    return t == 'created_at'
  },
  br: | t | {
    return t.replace('\n', '<br>')
  },
  draw: | t | {
    return drawdown.markdown(t)
  },
  can_revert: | versions | {
    return versions.length() > 1
  },
  no_ext: | t | {
    return t.split('.')[0]
  },
  file_title: | t | {
    /* return ' '.join(iters.map(t.split('.')[0].split('-'), | x | {
      if x.length() > 1 return x[0].upper() + x[1,].lower()
      return x.lower()
    })) */
    var x = t.split('.')[0].replace('-', ' ')
    return x[0].upper() + x[1,]
  }
}

def get_attrs(attrs) {
  return iters.reduce(attrs, | dict, attr | {
    dict.set(attr.key, attr.value)
    return dict
  }, {})
}

def strip(txt) {
  # remove comments and surrounding white space
  return txt.trim().replace('/(?=<!--)([\s\S]*?)-->\\n*/m', '')
}

def strip_attr(element, ...) {
  var attrs = __args__
  element.attributes = iters.filter(element.attributes, | el | {
    return !attrs.contains(el.key)
  })
}

def extract_var(variables, _var) {
  var var_split = _var.split('|')
  if var_split {
    var _vars = var_split[0].split('.')
    var real_var

    if variables.contains(_vars[0]) {
      if _vars.length() > 1 {
        var final_var = variables[_vars[0]]
        iter var i = 1; i < _vars.length(); i++ {
          if is_dict(final_var) {
            final_var = final_var[_vars[i].matches('/^\d+$/') ? to_number(_vars[i]) : _vars[i]]
          } else if (is_list(final_var) or is_string(final_var)) and _vars[i].matches('/^\d+$/') {
            final_var = final_var[to_number(_vars[i])]
          } else {
            die Exception('could not resolve ${_var} at ${_vars[i]}')
          }
        }

        real_var = final_var
      } else {
        real_var = variables[_vars[0]]
      }

      if var_split.length() > 1 {
        iter var i = 1; i < var_split.length(); i++ {
          if functions.contains(var_split[i]) {
            real_var = functions[var_split[i]](real_var)
          }
        }
      }

      return real_var
    }
  }

  return ''
}

def replace_vars(content, variables) {
  # replace variables: {var_name}
  # 
  # NOTE: This must come last as previous actions could generate or 
  # contain variables as well.
  var var_vars = content.matches('~(?<![{])\{(?P<variable>([a-zA-Z_][a-zA-Z0-9_|]*(\.[a-zA-Z0-9_|]+)*))\}~')
  if var_vars {
    # var_vars = json.decode(json.encode(var_vars))
    for _var in var_vars.variable {
      content = content.replace('{${_var}}', to_string(extract_var(variables, _var)))
    }
  }
  
  # strip variable escapes
  return content.replace('~\\{\\{~', '{')
}

def process(path, element, variables) {
  if !element return nil

  if is_string(element) {
    return replace_vars(element, variables)
  }

  if is_list(element) {
    return iters.map(element, | el | {
      return process(path, el, variables)
    }).compact()
  }

  def error(message) {
    die Exception('${message} at ${path}[${element.position.start.line},${element.position.start.column}]')
  }
  
  if element.type == 'text' {
    # replace variables: {var_name}
    element.content = process(path, element.content, variables)
    return element
  } else {
    var attrs = get_attrs(element.attributes)

    if element {
      # process special elements

      using element.tagName {
        # include tags
        when 'include' {
          if !attrs or !attrs.contains('path')
            error('missing "path" attribute for include tag')
  
          var includePath = os.join_paths(templates_directory, attrs.path)
          if !includePath.match('/[.][a-zA-Z]+$/') includePath += '.html'
          var fl = file(includePath)
          if fl.exists() {
            element = process(includePath, cocoa.decode(strip(fl.read()), {includePositions: true}), variables)
          } else {
            error('file "${attrs.path}" not found')
          }
        }
      }
    }

    # process directives

    if attrs.contains('ny-if') {
      # if tag
      var _var = extract_var(variables, attrs.get('ny-if'))
      if _var {
        strip_attr(element, 'ny-if')
        element = process(path, element, variables)
      } else {
        element = nil
      }
    } else if attrs.contains('ny-not') {
      # if not tag
      var _var = extract_var(variables, attrs.get('ny-not'))
      if !_var {
        strip_attr(element, 'ny-not')
        element = process(path, element, variables)
      } else {
        element = nil
      }
    } else if attrs.contains('ny-for') {
      # for tag
      if !attrs or !attrs.contains('ny-key')
        error('missing "ny-key" attribute for `for` tag')
      
      var data = extract_var(variables, attrs.get('ny-for')),
          key_name = attrs.get('ny-key'),
          value_name = attrs.get('ny-value', nil)

      strip_attr(element, 'ny-for', 'ny-key', 'ny-value')
      var for_vars = variables.clone()

      var result = []
      for key, value in data {
        for_vars.set('${key_name}', value_name ? key : value)
        if value_name for_vars.set('${value_name}', value)
        result.append(process(path, json.decode(json.encode(element)), for_vars))
      }
      return result
      /* return iters.map(data, |value, key| {
        for_vars.set('${key_name}', value_name ? key : value)
        if value_name for_vars.set('${value_name}', value)
        return process(path, json.decode(json.encode(element)), for_vars)
      }) */
    }
    
    if element and element.contains('children') and element.children {
      element.children = process(path, element.children, variables)
    }

    # replace attribute variables...
    if element and !is_list(element) {
      for attr in element.attributes {
        if attr.value {
          # replace variables: {var_name}
          attr.value = process(path, attr.value, variables)
        }
      }
    }

    return element
  }
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
    var file_content = strip(template_file.read())

    return cocoa.encode(
      process(
        path,
        cocoa.decode(file_content, {includePositions: true}),
        variables
      )
    )
  }

  die Exception('template ${name} not found')
}
