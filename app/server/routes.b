import .views
import .statics

var routes = {
  '/static/*': ['GET', statics.handler],
  '/': ['GET', views.home],
  '/create-package': ['POST', views.create_package],
  '/get-package': ['GET', views.get_package],
  '/create-publisher': ['POST', views.create_publisher],
  '/login': ['POST', views.login],
}
