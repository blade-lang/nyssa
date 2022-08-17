import args
import os
import json
import ..setup
import ..log
import ..config { Config }

var blade_exe = os.args[0]
var libs_dir = os.join_paths(os.cwd(), '.blade/libs')

def parse(parser) {
  parser.add_command(
    'uninstall', 
    'Uninstalls a Blade package', 
    {
      type: args.STRING,
    }
  ).add_option(
    'global', 
    'package is a global package', 
    {
      short_name: 'g',
    }
  )
}

def run(value, options, success, error) {
  var is_global = options.get('global', false)
  var package_not_installed = 'package ${value} not installed.'

  if os.dir_exists(libs_dir) {
    var package_dir = os.join_paths(libs_dir, value),
        package_config_file = os.join_paths(package_dir, setup.CONFIG_FILE),
        this_config_file = os.join_paths(os.cwd(), setup.CONFIG_FILE)

    if !file(this_config_file).exists()
      error('Not in a Nyssa package.')

    var this_config = Config.from_dict(json.decode(file(this_config_file).read()))
    if !this_config.name or !this_config.version
      error('Not in a Nyssa package.')

    if os.dir_exists(package_dir) {
      try {
        var pf = file(package_config_file)
        if pf.exists() {
          var package_config = Config.from_dict(json.decode(pf.read()))
          # run pre uninstall script if it exists
          if package_config.pre_uninstall {
            log.info('Running pre uninstall for ${value}...')

            # cd into the destination before running pre_uninstall so 
            # that pre_uninstall will run relative to the package.
            var this_dir = os.cwd()
            os.change_dir(package_dir)

            # run the script
            os.exec('${blade_exe} ${package_config.pre_uninstall}')

            # return to current directory
            os.change_dir(this_dir)
          }
        }

        log.info('Uninstalling ${value}...')
        # uninstall the package
        os.remove_dir(package_dir, true)

        # remove dependency from config
        if this_config.deps and this_config.deps.contains(value)
          this_config.deps.remove(value)

        file(this_config_file, 'w').write(json.encode(this_config, false))

        success('${value} uninstalled successfully!')
      } catch Exception e {
        error(e.message)
      }
    } else {
      error(package_not_installed)
    }
  } else {
    error(package_not_installed)
  }
}
