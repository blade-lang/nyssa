# nyssa
Nyssa is a friendly package manager and repository for the Blade programming language.


## Features

- [x] Create packages.
- [x] Manage application dependencies 
  - [x] Install package
  - [x] Uninstall package
  - [x] Update (Install without specifying a version)
  - [x] Restore package
  - [x] Publish package
- [x] Built-in hostable repository server.
- [x] Publish package to public and private repositories.
- [x] Nyssa repository server public API.
- [ ] Nyssa repository server searchable frontend website.
- [x] Manage publisher accounts.
  - [x] Create publisher account
  - [x] Login to publisher account
  - [x] Logout from publisher account
- [x] Custom Post-Installation script support.
- [x] Custom Pre-Uninstallation script support.
- [ ] Generate application/library documentation.


## Installation

- Clone the repository to the desired host directory using the command below:
  
  ```sh
  git clone https://github.com/blade-lang/nyssa.git
  ```

- Add the full path to `nyssa` to path (steps depend on operating system).


## Commands

To get a list of commands available, their options and usage after installation, simply type `nyssa` in a terminal and press the ENTER key. You should see something similar to the following:

```
Usage: nyssa [ [-h] | [-v] ] [COMMAND]

OPTIONS:
  -h, --help                Show this help message and exit
  -v, --version             Show Nyssa version

COMMANDS:
  account <choice>          Manages a Nyssa publisher account
    create                    creates a new publisher account
    login                     login to a publisher account
    logout                    log out of a publisher account
    -r, --repo <value>        the repo where the account is located
  clean                     Clear Nyssa storage
    -c, --cache               clean packages cache
    -l, --logs                clean logs
    -a, --all                 clean everything
  info                      Shows current project information
  init                      Creates a new package in current directory
    -n, --name <value>        the name of the package
  install <value>           Installs a Blade package
    -g, --global              installs the package globally
    -c, --use-cache           enables the cache
    -r, --repo <value>        the repository to install from
  publish                   Publishes a repository
    -r, --repo <value>        repository url
  restore                   Restores all project dependencies
    -x, --no-cache            disables the cache
  serve                     Starts a local Nyssa repository server
    -p, --port <value>        port of the server (default: 3000)
    -n, --host <value>        the host ip (default: 127.0.0.1)
  uninstall <value>         Uninstalls a Blade package
    -g, --global              package is a global package
```

_Nyssa_ will throw an error and hint you on proper usage when you use it wrong or pass invalid arguments to it.

