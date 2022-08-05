import json
import .template

def home(req, res) {
  res.write(template('home'))
}
