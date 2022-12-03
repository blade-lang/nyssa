import args
import hash
import os
import colors
import http
import json
import io
import zip
import ..setup
import ..log
import ..config { Config }


var cache_dir = os.join_paths(os.args[1], setup.CACHE_DIR)
if !os.dir_exists(cache_dir)
  os.create_dir(cache_dir)

var config_file = os.join_paths(os.cwd(), setup.CONFIG_FILE)

def bold(t) {
  return colors.text('${t} ', colors.style.bold)
}

def green(t) {
  return colors.text(t, colors.text_color.green)
}

def parse(parser) {
  parser.add_command(
    'install', 
    'Installs a Blade package', 
    {
      type: args.STRING,
    }
  ).add_option(
    'global', 
    'installs the package globally', 
    {
      short_name: 'g',
    }
  ).add_option(
    'silent', 
    'runs the installation without confirmation', 
    {
      short_name: 's',
    }
  ).add_option(
    'no-cache', 
    'disables the cache', 
    {
      short_name: 'x',
    }
  ).add_option(
    'repo', 
    'the repository to install from', 
    {
      short_name: 'r',
      type: args.OPTIONAL
    }
  )
}

/**
 * @DONE:
 * - Support for running custom setup script on installation.
 * @TODO: 
 * - Add support for copying binary files to bin directory.
 */
def configure(config, repo, full_name, name, version, path, is_global, no_cache, count, error) {
  log.info('Installing ${full_name}')

  var blade_exe = os.args[0]

  var destination
  if !is_global destination = os.join_paths(os.cwd(), '.blade/libs/${name}')
  else destination = os.join_paths(os.dir_name(blade_exe), 'vendor/${name}')

  # create the packages directory if not exists
  log.info('Creating package directory for ${full_name}')
  if os.dir_exists(destination)
    os.remove_dir(destination, true)
  os.create_dir(destination)

  # extract
  log.info('Extracting artefact for ${full_name}')
  if zip.extract(path, destination) {
    var package_config_file = os.join_paths(destination, setup.CONFIG_FILE)
    var package_config = Config.from_dict(json.decode(file(package_config_file).read()))

    # run post install script if it exists
    if package_config.post_install {
      log.info('Running post install for ${full_name}')

      # cd into the destination before running post_install so 
      # that post_install will run relative to the package.
      var this_dir = os.cwd()
      os.change_dir(destination)

      # run the script
      os.exec('${blade_exe} ${package_config.post_install}')

      # return to current directory
      os.change_dir(this_dir)
    }

    log.info('Updating dependency state for project')

    try {
      if count == 1 {
        if config.deps.contains(name) and version == nil {
          # do nothing...
        } else {
          config.deps[name] = package_config.version
          file(config_file, 'w').write(json.encode(config, false))
        }

        # update sources if not already listed
        if !config.sources.contains(repo) {
          config.sources.append(repo)
        }
      }

      if package_config.deps {
        echo ''
        log.info('Fetching dependencies for ${full_name}...')
        echo '--------------------------${"-" * full_name.length()}---'

        for dep, ver in package_config.deps {
          var dep_full_name = ver ? '${dep}@${ver}' : dep
          install(config, repo, dep_full_name, dep, ver, is_global, no_cache, count, error)
        }
      }
    } catch Exception e {
      echo colors.text(
        'Dependency state update failed!\n' + 
        'You can manually fix it by adding the following to the dependency section of you ' + setup.CONFIG_FILE + ' file.\n' +
        '\n\t"${name}": ' + (version ? '"${version}"' : "null") +  '\n\n' +
        'If the section is not empty add a comma (,) and press ENTER before adding the fix.\n', 
        colors.text_color.orange
      )
      error(e.message)
    }
  } else {
    error('${name} installation failed:\n  Failed to extract package source')
  }
}

def install(config, repo, full_name, name, version, is_global, no_cache, count, error) {
  # increment number of installed packages.
  count++

  if !no_cache log.info('Checking local cache for ${name}@${version}')
  var cache_id = hash.sha1(repo + name + version)
  var cache_path = os.join_paths(cache_dir, '${cache_id}.nyp')

  try {

    # check local cache first to avoid redownloading all the time...
    if file(cache_path).exists() and !no_cache {
      configure(config, repo, full_name, name, nil, cache_path, is_global, no_cache, count, error)
      return
    }

    # fresh install
    log.info('-> Fetching package metadata for ${full_name}')
    var res = http.get('${repo}/get-package/${full_name}')
    var body = json.decode(res.body.to_string())

    if res.status == 200 {
      if count == 1 {
        echo ''
        echo green(bold('PACKAGE FOUND'))
        echo green('-------------')
        echo bold('Name:') + body.name
        echo bold('Version:') + body.version
        echo bold('Description:') + body.description
        echo bold('Homepage:') + body.homepage
        echo bold('Author:') + body.author
        echo bold('License:') + body.license
        echo bold('Publisher:') + body.publisher
        echo ''
      } else {
        log.info('${name} dependency ${body.name}@${body.version} found')
      }

      # download source
      log.info('Downloading package source for ${full_name}')
      var download_url = repo + '/source/' + body.source
      var download_req = http.get(download_url)
      if download_req.status == 200 {
        # save the file to cache
        log.info('Caching download for ${full_name}')
        file(cache_path, 'wb').write(download_req.body)

        # do the real installation
        configure(config, repo, full_name, name, body.version, cache_path, is_global, no_cache, count, error)
      } else {
        error('package source not found')
      }
    } else {
      error('${full_name} installation failed:\n  ${body.error}')
    }
  } catch Exception e {
    error('${full_name} installation failed:\n  ${e.message}')
  }
}

def run(value, options, success, error) {
  var repo = options.get('repo', setup.DEFAULT_REPOSITORY),
      is_global = options.get('global', false),
      no_cache = options.get('no-cache', false),
      count = 0

  if !file(config_file).exists() 
    error('Not in a Nyssa project')
  
  var config = json.decode(file(config_file).read())
  if !is_dict(config) or !config.get('name', nil) or !config.get('version', nil)
    error('Not in a Nyssa project')

  config = Config.from_dict(config)

  var ns = value.split('@'),
      name = ns[0],
      version = ns.length() > 1 ? ns[1] : nil,
      full_name = version ? '${name}@${version}' : name

  var config_check = config.deps.get(name, nil)
  if config_check
    if version == nil or config_check == version
      success('${value} is already installed.')

  install(config, repo, full_name, name, version, is_global, no_cache, count, error)
  success('${full_name} installed successfully!')
}
