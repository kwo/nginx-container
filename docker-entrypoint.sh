#!/bin/sh
set -e

# Replace environment variables in nginx config
envsubst '${AUTH_TOKEN}' < /etc/nginx/conf.d/default.conf > /tmp/default.conf
mv /tmp/default.conf /etc/nginx/conf.d/default.conf

# Execute the CMD
exec "$@"
