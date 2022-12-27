# FROTEND WEB PAGES
import json
import bcrypt
import .template
import .db
import .util
import ..setup

def home(req, res) {
  res.write(template('home', {
    publishers: db.get_publishers_count(),
    packages: db.get_packages_count(),
    downloads: db.get_all_download_count(),
    top_packages: db.get_top_packages(),
    latest_packages: db.get_top_packages('created_at DESC'),
    show_login: !res.session.contains('user'),
  }))
}

def search(req, res) {
  if !req.queries.contains('q') {
    # redirect to home
    res.redirect('/')
    return
  }

  var query = req.queries.q
  var page = to_number(req.queries.get('page', '1'))
  var sort = req.queries.get('sort', nil) ? req.queries.sort : 'downloads'
  var real_sort = sort == 'name' ? '${sort} ASC' : '${sort} DESC'

  var result = db.search_package('%${query}%', page, real_sort)
  for pack in result.packages {
    pack.tags = json.decode(pack.tags)
  }

  var pg = 1..(result.pages + 1)
  if result.pages > 11 and page >= 6 {
    var start = page - 5, end = page + 5 + 1
    if end > result.pages end = result.pages
    pg = start..end
  }

  var pagination = []
  for x in pg {
    if x == page pagination.append({page: x, active: true})
    else pagination.append({page: x, active: false})
  }

  res.write(template('search', {
    query: query,
    result: result,
    pages: pagination,
    sort: sort,
    show_login: !res.session.contains('user'),
  }))
}

def view(req, res) {
  var id = req.params.id
  var name = id, version
  if id.match('@') {
    var id_split = id.split('@')
    name = id_split[0]; version = id_split[1]
  }
  var package = db.get_package(name, version)
  if package {
    package.deps = json.decode(package.deps)
    package.tags = json.decode(package.tags)
    package['versions'] = db.get_package_versions(name)
  } else {
    if !req.queries.contains('q') {
      # redirect to home
      res.redirect('/404')
      return
    }
  }
  res.write(template('view', {
    package: package,
    name: req.params.id,
    version: version,
    show_login: !res.session.contains('user'),
  }))
}

def authenticate(req, res) {
  if res.session.contains('user') {
    res.redirect('/account')
    return
  }

  if req.body and is_dict(req.body) {
    var name = req.body.get('username', nil),
      password = req.body.get('password', nil)

    if name and password {
      var pub = db.get_publisher(name)

      # authenticate
      if pub and bcrypt.compare(password, pub.password) {
        res.session['user'] = pub
        res.redirect('/account')
        return
      }
    }
  }

  res.redirect('/login?error=1')
}

def login(req, res) {
  if res.session.contains('user') {
    res.redirect('/account')
    return
  }

  res.write(template('login', {
    show_login: true,
    error: req.queries.get('error', nil)
  }))
}

def account(req, res) {
  if !res.session.contains('user') {
    res.redirect('/login')
    return
  }

  var page = to_number(req.queries.get('page', '1'))
  var result = db.get_user_packages(res.session['user'].username, page)
  for pack in result.packages {
    pack.tags = json.decode(pack.tags)
    pack.versions = db.get_package_versions(pack.name)
  }

  var pg = 1..(result.pages + 1)
  if result.pages > 11 and page >= 6 {
    var start = page - 5, end = page + 5 + 1
    if end > result.pages end = result.pages
    pg = start..end
  }

  var pagination = []
  for x in pg {
    if x == page pagination.append({page: x, active: true})
    else pagination.append({page: x, active: false})
  }

  res.write(template('account', {
    result: result,
    pages: pagination,
    show_login: false,
    user: res.session['user'],
    message: res.session.remove('message')
  }))
}

def revert(req, res) {
  if !res.session.contains('user') {
    res.redirect('/login')
    return
  }
  
  if req.body and is_dict(req.body) {
    var name = req.body.get('name', nil),
      version = req.body.get('version', nil)

    if name and version {
      var package = db.get_package(name, version)
      if package {
        if db.revert_package(name, package.id) {
          # create flash message
          res.session['message'] = 'Package <strong>${name}</strong> successfully reverted to version <strong>${version}</strong>'
        }
        res.redirect('/account')
        return
      }
    }
  }

  res.redirect('/login')
}
