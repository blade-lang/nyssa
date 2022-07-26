class Config {
  var name
  var version
  var description
  var homepage
  var tags
  var author
  var license
  var deps

  static from_dict(dict) {
    var c = Config()

    c.name = dict.get('name', nil)
    c.version = dict.get('version', '1.0.0')
    c.description = dict.get('description', nil)
    c.homepage = dict.get('homepage', nil)
    c.tags = dict.get('tags', [])
    c.author = dict.get('author', nil)
    c.license = dict.get('license', 'ISC')
    c.deps = dict.get('deps', {})

    return c
  }

  @to_json() {
    return {
      name: self.name,
      version: self.version,
      description: self.description,
      homepage: self.homepage,
      tags: self.tags,
      author: self.author,
      license: self.license,
      deps: self.deps,
    }.compact()
  }
}
