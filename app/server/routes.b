import .views
import .statics

var routes = {
  '/static/*': ['GET', statics.handler],
  '/': ['GET', views.home],
  '/create-package': ['POST', views.create_package],
  '/create-publisher': ['POST', views.create_publisher],
}
