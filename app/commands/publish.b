import args
import os
import json
import http
import colors
import zip
import ..setup
import ..log
import ..config { Config }

var storage_dir = os.join_paths(os.args[1], setup.STORAGE_DIR)

def italics(t) {
  return colors.text(t, colors.style.italic)
}

def parse(parser) {
  parser.add_command(
    'publish', 
    'Publishes a repository'
  ).add_option(
    'repo', 
    'repository url', 
    {
      short_name: 'r',
      type: args.OPTIONAL,
    }
  )
}

def run(value, options, success, error) {
  var repo = options.get('repo', setup.DEFAULT_REPOSITORY),
      state_file = os.join_paths(os.args[1], setup.STATE_FILE),
      config_file = os.join_paths(os.cwd(), setup.CONFIG_FILE),
      tmp_dest

  try {
    log.info('Checking for valid publisher account.')
    var state = json.decode(file(state_file).read().trim()  or '{}')
    if !state.get('name', nil) or !state.get('key', nil)
      error(
        'Publisher account not authenticated.\n' + 
        'Run "nyssa account create" or "nyssa account login" to get started.'
      )

    log.info('Checking for valid Nyssa package.')
    var config = Config.from_dict(json.decode(file(config_file).read()))
    if !config.name or !config.version
      error('Invalid Nyssa package.')

    var source_name = '${state.name}_${config.name}_${config.version}.nyp'
    tmp_dest = os.join_paths(storage_dir, source_name)

    log.info('Packaging ${config.name}@${config.version}...')
    if zip.compress(os.cwd(), tmp_dest) {
      var client = http.HttpClient()

      # set authentication headers
    log.info('Authenticating.')
      client.headers = {
        'Nyssa-Publisher-Name': state.name,
        'Nyssa-Publisher-Key': state.key,
      }

      # make the request
      log.info('Uploading ${config.name}@${config.version} to ${repo}...')
      var res = client.send_request('${repo}/create-package', 'POST', {
        name: config.name,
        version: config.version,
        config: json.encode(config),
        source: file(tmp_dest),
      })
      var body = json.decode(res.body.to_string())

      # delete the package source file
      log.info('Removing temporary files.')
      file(tmp_dest).delete()

      if res.status == 200 {
        success('Successfully published ${config.name}@${config.version}!')
      } else {
        error('Publish failed for ${config.name}@${config.version}: ${body.error}')
      }
    } else {

      file(tmp_dest).delete()
      error('Packaging failure.')
    }
  } catch Exception e {
    error(e.message)
  } finally {
    if tmp_dest file(tmp_dest).delete()
  }
}
