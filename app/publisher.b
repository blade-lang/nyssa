import .config
import date

class Publisher {
  var name
  var email
  var password
  var key
  var active = true
  var created_at
  var deleted_at

  Publisher(name, email, password, key, created_at) {
    self.name = name
    self.email = email
    self.password = password
    self.key = key
    self.created_at = created_at ? created_at : date()
  }

  static from_dict(dict) {
    var package = Publisher(dict.name, dict.email, dict.password, dict.key, dict.get('created_at', date().format('c')))
    package.active = dict.get('active', true)
    package.deleted_at = dict.get('deleted_at', nil)
    return package
  }

  @to_json() {
    return {
      name: self.name,
      email: self.email,
      key: self.key,
      active: self.active,
      created_at: self.created_at,
      deleted_at: self.deleted_at,
    }
  }
}

def publisher(name, email, password, key) {
  return Publisher.from_dict({
    name: name,
    email: email,
    password: password,
    key: key,
  })
}
