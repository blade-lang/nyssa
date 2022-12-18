import .api
import .views
import .statics

var routes = {
  # api endpoints
  '/static/*': ['GET', statics.static_handler],
  '/source/*': ['GET', statics.source_handler],
  '/packages': ['GET', api.all_package],
  '/create-package': ['POST', api.create_package],
  '/get-package/{name}': ['GET', api.get_package],
  '/create-publisher': ['POST', api.create_publisher],
  '/login': ['POST', api.login],

  # frontend website pages
  '/': ['GET', views.home],
  '/search': ['GET', views.search],
}
