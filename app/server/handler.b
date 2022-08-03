import json

def handler(req, res) {
  res.write(json.encode(req))
  for f in req.files {
    file('uploads/${f.filename}', 'wb').write(f.content)
  }
}
