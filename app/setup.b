# general
var NYSSA_VERSION = '0.0.1'

# directories
var APP_DIR = 'app'
var TEST_DIR = 'tests'
var EXAMPLES_DIR = 'examples'
var STATIC_DIR = 'public'
var TEMPLATES_DIR = 'templates'
var STORAGE_DIR = 'storage'
var LOGS_DIR = '${STORAGE_DIR}/logs'
var SOURCES_DIR = '${STORAGE_DIR}/sources'
var DATABASE_DIR = '${STORAGE_DIR}/db'
var CACHE_DIR = '${STORAGE_DIR}/cache'

# files
var INDEX_FILE = 'index.b'
var README_FILE = 'README.md'
var CONFIG_FILE = 'nyssa.json'
var DATABASE_FILE = '${DATABASE_DIR}/nyssa.db'
var STATE_FILE = '${STORAGE_DIR}/config.json'

# repository
var REPOSITORY_HOST = '127.0.0.1'
var REPOSITORY_PORT = 3000

var DEFAULT_REPOSITORY = '${REPOSITORY_HOST}:${REPOSITORY_PORT}'
