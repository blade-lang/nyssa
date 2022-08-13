import .views
import .statics

var routes = {
  '/static/*': ['GET', statics.static_handler],
  '/source/*': ['GET', statics.source_handler],
  '/': ['GET', views.home],
  '/create-package': ['POST', views.create_package],
  '/get-package/{name}': ['GET', views.get_package],
  '/create-publisher': ['POST', views.create_publisher],
  '/login': ['POST', views.login],
}
