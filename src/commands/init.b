import args
import os
import io
import iters
import colors
import ..config {
  Config
}
import ..setup
import json

def parse(parser) {
  parser.add_command(
    'init', 
    'Creates a new package in current directory'
  ).add_option(
    'name', 
    'the name of the package', 
    {
      short_name: 'n',
      type: args.OPTIONAL,
    }
  )
}

def run(value, options, success, error) {

  # Declare locations...
  var here = os.cwd(),
      test_dir = os.join_paths(here, setup.TEST_DIR),
      ex_dir = os.join_paths(here, setup.EXAMPLES_DIR)
  var test_ignore = test_dir + os.path_separator + '.gitignore',
      ex_ignore = ex_dir + os.path_separator + '.gitignore',
      index = here + os.path_separator + setup.INDEX_FILE,
      readme = here + os.path_separator + setup.README_FILE,
      config_file = here + os.path_separator + setup.CONFIG_FILE,
      attr_file = here + os.path_separator + '.gitattributes',
      ignore_file = file(here + os.path_separator + '.gitignore', 'w+')

  if file(config_file).exists() {
    error('Cannot create new package where one exists.')
    return
  }

  var config = get_package_config()

  if !config.name {
    error('Package must specify a name.')
  }

  # Create tests and examples directory
  if !os.dir_exists(test_dir) os.create_dir(test_dir)
  if !os.dir_exists(ex_dir) os.create_dir(ex_dir)

  # Create .gitignore files in tests and examples directory for 
  # git compartibility.
  var tf = file(test_ignore, 'w+')
  tf.open(); tf.close()
  var ef = file(ex_ignore, 'w+')
  ef.open(); ef.close()

  # create the index file
  var inf = file(index, 'w+')
  inf.open(); inf.close()

  # Create the README.md file if one does not exists.
  if !file(readme).exists() {
    file(readme, 'w').write(
      '# ${config.name}\n' + 
      '\n' +
      '${config.description or "_Package description goes here._"}_n' +
      '\n' +
      '### Package Information\n' + 
      '\n' + 
      '- **Name:** ${config.name}\n' +
      '- **Version:**: ${config.version}\n' +
      '- **Homepage:**: ${config.homepage or "_Homepage goes here._"}\n' +
      '- **Tags:**: ${", ".join(config.tags) or "_Tags goes here._"}\n' +
      '- **Author:**: ${config.author or "_Author info goes here._"}\n' +
      '- **License:**: ${config.license or "_License name or link goes here._"}\n' +
      '\n'
    )
  }

  # increase Blade visibility by setting the attribute file properties
  # to allow Github identify it as a Blade project.
  file(attr_file, 'w').write('*.b linguist-detectable\n' +
        '*.b linguist-language=Blade\n')

  # create default gitignore file to disable popular editor extensions
  # and the .blade directory.
  # 
  # this will only happen if the file does not exist or does not contain 
  # the blade default ignore definitions.
  if !ignore_file.exists() or !ignore_file.contains(
    '# blade packages directory and files'
  ) {
    ignore_file.write(
      '# blade packages directory and files\n' +
      '.blade/\n' +
      '*.nyp\n' +   # nyssa package object file
      '\n' +
      '# popular editors\n' +
      '.vscode/\n' +
      '.idea/\n' +
      '.vs/\n' +
      '\n' +
      '# c object files (for C extensions)\n' +
      '*.o\n' +
      '*.ko\n' +
      '*.obj\n' +
      '*.elf\n' +
      '\n' +
      '# log files\n' +
      '*.log\n'
    )
  }

  # Create the nyssa.json file...
  file(config_file, 'w').write(json.encode(config, false))

  success('Package created!')
}

def _default(t) {
  return colors.text(colors.text('(default: ${t})', colors.text_color.dark_grey), colors.style.italic)
}

def get_package_config() {
  return Config.from_dict({
    name: io.readline('package name:').trim(),
    version: io.readline('version ${_default("1.0.0")}:').trim() or '1.0.0',
    description: io.readline('description:').trim(),
    homepage: io.readline('homepage:').trim(),
    tags: iters.map(io.readline('tags:').trim().split(','), |x| {
      return x.trim()
    }),
    author: io.readline('author:').trim(),
    license: io.readline('license ${_default("ISC")}:').trim() or 'ISC',
  })
}
