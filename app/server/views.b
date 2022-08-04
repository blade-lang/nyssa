import json

def home(req, res) {
  res.write(req.params.id)
}
