# FROTEND WEB PAGES
import json
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
    sort: sort
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
  }
  res.write(template('view', {
    package: package,
    name: req.params.id,
    version: version
  }))
}
