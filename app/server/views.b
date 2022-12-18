# FROTEND WEB PAGES
import json
import .template
import .db
import .util

def home(req, res) {
  res.write(template('home', {
    publishers: util.format_number(db.get_publishers_count()),
    packages: util.format_number(db.get_packages_count()),
    downloads: util.format_number(db.get_all_download_count()),
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
  var result = db.search_package('%${query}%')

  res.write(template('search', {
    query: query,
    result: result,
  }))
}
