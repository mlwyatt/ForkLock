#!/usr/bin/env bash
set -o errexit

bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails server -b 0.0.0.0
