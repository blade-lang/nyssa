import .api
import .views
import .statics

var routes = {
  # api endpoints
  '/static/*': ['GET', statics.static_handler],
  '/source/*': ['GET', statics.source_handler],
  '/api/packages': ['GET', api.all_package],
  '/api/create-package': ['POST', api.create_package],
  '/api/get-package/{name}': ['GET', api.get_package],
  '/api/create-publisher': ['POST', api.create_publisher],
  '/api/login': ['POST', api.login],

  # frontend website pages
  '/': ['GET', views.home],
  '/login': ['GET', views.login],
  '/auth': ['POST', views.authenticate],
  '/account': ['GET', views.account],
  '/search': ['GET', views.search],
  '/view/{id}': ['GET', views.view],
}
