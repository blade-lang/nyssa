import .loader

var help_action = 'help'

def call_action(action, args) {
  if is_function(action) {
    action(args)
  } else {
    action.run(args)
  }
}

def run(args) {
  var action = args ? args[0] : help_action
  if !loader.map.contains(action) {
    echo 'Unknown command: "${action}"'
    echo ''
    action = help_action
  }
  call_action(loader.map[action], args[1,])
}
