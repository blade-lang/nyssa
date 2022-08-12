import args
import ..setup

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

def run(value, options, success, error) {
  
}
