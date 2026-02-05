#!/bin/bash
set -e

# https://github.com/webpack/webpack/issues/14532#issuecomment-949499445
export NODE_OPTIONS=--openssl-legacy-provider

bundle install
yarn install

# Remove a potentially pre-existing server.pid for Rails.
rm -f /$APP_PATH/tmp/pids/server.pid

# run passed commands
exec "$@"
