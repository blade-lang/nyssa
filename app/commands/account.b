import args
import io
import os
import http
import json
import ..setup
import ..log

# read the config file
var config_file = os.join_paths(os.args[1], setup.STATE_FILE)
var config = json.decode(file(config_file).read().trim() or '{}')
if !is_dict(config) config = {}

def parse(parser) {
  parser.add_command(
    'account', 
    'Manage a Nyssa publisher account',
    {
      type: args.CHOICE,
      # choices: ['create', 'login', 'logout'],
      choices: {
        create: 'creates a new publisher account',
        login: 'login to a publisher account',
        logout: 'log out of a publisher account',
      }
    }
  ).add_option(
    'repo', 
    'the repo where the account is located', 
    {
      short_name: 'r',
      type: args.OPTIONAL,
    }
  )
}

def create(repo, success, error) {
  # warn about account overwrite
  if config.get('name', nil) and config.get('key', nil) {
    var name = config['name']
    echo 'Account "${name}" currently logged in. If you continue, ${name} will be logged out.'
    if !['y', 'Y'].contains(io.readline('Do you want to continue? [y/N]').trim())
      return
  }

  var details = {
    name: io.readline('username:').trim(),
    email: io.readline('email:').trim(),
    password: io.readline('password:', true).trim(),
  }
  echo '' # because password prompt won't go to a new line.

  try {
    log.info('Creating new publisher account at ${repo}.')
    var res = http.post('${repo}/create-publisher', details)
    var body = json.decode(res.body.to_string())

    if res.status == 200 {

      # update the config
      config['name'] = details.name
      config['email'] = details.email
      config['key'] = body.key
      file(config_file, 'w').write(json.encode(config, false))

      success(
        'Account created successfully!\n' +
        'Publisher Key: ${body.key}'
      )
    } else {
      error('Account creation failed: ${body.error}')
    }
  } catch Exception e {
    error('Account creation failed: ${e.message}')
  }
}

def login(repo, success, error) {
  # warn about account overwrite
  if config.get('name', nil) and config.get('key', nil) {
    var name = config['name']
    echo 'Account "${name}" currently logged in. If you continue, ${name} will be logged out.'
    if !['y', 'Y'].contains(io.readline('Do you want to continue? [y/N]').trim())
      return
  }

  var details = {
    username: io.readline('username:').trim(),
    password: io.readline('password:', true).trim(),
  }
  echo '' # because password prompt won't go to a new line.

  try {
    log.info('Login in to publisher account at ${repo}.')
    var res = http.post('${repo}/login', details)
    var body = json.decode(res.body.to_string())

    if res.status == 200 {

      # update the config
      config['name'] = body.username
      config['email'] = body.email
      config['key'] = body.key
      
      file(config_file, 'w').write(json.encode(config, false))
      success(
        'Logged in as ${body.username} successfully!\n' +
        'Publisher Key: ${body.key}'
      )
    } else {
      error('Login failed: ${body.error}')
    }
  } catch Exception e {
    error('Login failed: ${e.message}')
  }
}

def logout(repo, success, error) {
  if config.get('name', nil)
    config.remove('name')
  if config.get('key', nil)
    config.remove('key')

  try {
    if file(config_file, 'w').write(json.encode(config, false))
      success('Logged out of publisher account!')
  } catch Exception e {
    error('Login failed: ${e.message}')
  }
}

def run(value, options, success, error) {
  var repo = options.get('repo', setup.DEFAULT_REPOSITORY)

  using value {
    when 'login' login(repo, success, error)
    when 'create' create(repo, success, error)
    when 'logout' logout(repo, success, error)
  }
}
