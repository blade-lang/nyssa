import sqlite
import os
import json

import ..log
import ..setup

var db_file = os.join_paths(os.args[1], setup.DATABASE_FILE)
var db_dir = os.dir_name(db_file)

if !os.dir_exists(db_dir)
  os.create_dir(db_dir)

var db = sqlite.open(db_file)

def create_tables() {
  # create the publishers table
  db.exec('CREATE TABLE IF NOT EXISTS publishers (' +
      'id INTEGER PRIMARY KEY,' +
      'username TEXT NOT NULL,' +
      'email TEXT NOT NULL,' +
      'password TEXT NOT NULL,' +
      'key TEXT NOT NULL,' +
      'active BOOLEAN DEFAULT TRUE,' +
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP,' +
      'deleted_at DATETIME NULL' +
    ');')

  # Create the packages table
  db.exec('CREATE TABLE IF NOT EXISTS packages (' +
      'id INTEGER PRIMARY KEY,' +
      'publisher TEXT NOT NULL,' +
      'name TEXT NOT NULL,' +
      'version TEXT NOT NULL,' +
      'source TEXT NOT NULL,' +
      'config TEXT NOT NULL,' +

      # extracted columns start
      'description TEXT GENERATED ALWAYS AS (json_extract(config, \'$.description\')) VIRTUAL,' +
      'homepage TEXT GENERATED ALWAYS AS (json_extract(config, \'$.homepage\')) VIRTUAL,' +
      'author TEXT GENERATED ALWAYS AS (json_extract(config, \'$.author\')) VIRTUAL,' +
      'license TEXT GENERATED ALWAYS AS (json_extract(config, \'$.license\')) VIRTUAL,' +
      'tags TEXT GENERATED ALWAYS AS (json_extract(config, \'$.tags\')) VIRTUAL,' +
      'deps TEXT GENERATED ALWAYS AS (json_extract(config, \'$.deps\')) VIRTUAL,' +
      # extracted columns end

      'downloads INTEGER DEFAULT 0,' +
      'active BOOLEAN DEFAULT TRUE,' +
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP,' +
      'deleted_at DATETIME NULL' +
    ');')
}

# PUBLISHERS

def get_publishers() {
  return db.query('SELECT * FROM publishers;')
}

def get_publisher(name, key) {
  var res
  if !key {
    res = db.fetch('SELECT * FROM publishers WHERE username = ? ORDER BY id DESC LIMIT 1;', [name])
  } else {
    res = db.fetch('SELECT * FROM publishers WHERE username = ? AND key = ? ORDER BY id DESC LIMIT 1;', [name, key])
  }

  if res return res[0]
  return nil
}

def check_publisher(name) {
  var res = db.fetch('SELECT * FROM publishers WHERE username = ? OR email = ? ORDER BY id DESC LIMIT 1;', [name, name])

  if res return res[0]
  return nil
}

def create_publisher(publisher) {
  if db.exec('INSERT INTO publishers (username, email, password, key) VALUES (?, ?, ?, ?);', [
    publisher.name, 
    publisher.email,
    publisher.password,
    publisher.key
  ])
    return db.last_insert_id()
  return 0
}

def delete_publisher(name) {
  return db.exec('DELETE FROM publishers WHERE username = ?;', [name])
}

# PACKAGES

def get_packages() {
  return db.query('SELECT * FROM packages;')
}

def get_package(name, version) {
  var res
  if !version {
    res = db.fetch('SELECT * FROM packages WHERE name = ? ORDER BY id DESC LIMIT 1;', [name])
  } else {
    res = db.fetch('SELECT * FROM packages WHERE name = ? and version = ? ORDER BY id DESC LIMIT 1;', [name, version])
  }

  if res return res[0]
  return nil
}

def create_package(package) {
  if db.exec('INSERT INTO packages (publisher, name, version, source, config) VALUES (?, ?, ?, ?, ?);', [
    package.publisher,
    package.name,
    package.version,
    package.source,
    json.encode(package.config)
  ]) return db.last_insert_id()
  return 0
}

def delete_package(name) {
  return db.exec('DELETE FROM packages WHERE name = ?;', [name])
}

# create tables if not exists...
create_tables()
