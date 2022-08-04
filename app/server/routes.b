import .views
import .statics

var routes = {
  '/static/*': statics.handler,
  '/': views.home,
}
