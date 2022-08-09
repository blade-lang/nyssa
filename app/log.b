import io
import date
import os
import .setup

var logs_dir = os.join_paths(os.args[1], setup.LOGS_DIR)
if !os.dir_exists(logs_dir)
  os.create_dir(logs_dir)

var time = date.localtime()
var _logfile = file(
  '${logs_dir}/${time.year}-${to_string(time.month).lpad(2,'0')}-${to_string(time.day).lpad(2,'0')}.log',
  'w+'
)

def _write(type, mes) {
  var time = date.localtime()
  var message = '[${time.year}-${to_string(time.month).lpad(2,'0')}-${to_string(time.day).lpad(2,'0')} ' + 
                '${to_string(time.hour).lpad(2,'0')}:${to_string(time.minute).lpad(2,'0')}:${to_string(time.seconds).lpad(2,'0')}' +
                '.${to_string(time.microseconds).lpad(6,'0')}] ${type} ${mes}\n'
  print(message)
  _logfile.write(message)
}

def info(message) {
  _write('INFO', message)
}

def debug(message) {
  _write('DEBUG', message)
}

def warn(message) {
  _write('WARN', message)
}

def error(message) {
  _write('ERROR', message)
}
