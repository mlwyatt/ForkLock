#!/usr/bin/env bash
set -o errexit

bundle install
yarn install
yarn build:js
bundle exec rails assets:precompile
