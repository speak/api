#!/bin/bash

bundle check || bundle install

bundle exec rackup -p 8080