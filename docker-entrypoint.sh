#!/bin/sh
set -e

# Generate AUTH_TOKEN from BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD
if [ -n "$BASIC_AUTH_USERNAME" ] && [ -n "$BASIC_AUTH_PASSWORD" ]; then
    # Create Basic Auth token in format "Basic base64(username:password)"
    AUTH_TOKEN="Basic $(printf '%s:%s' "$BASIC_AUTH_USERNAME" "$BASIC_AUTH_PASSWORD" | base64)"
    export AUTH_TOKEN
    echo "AUTH_TOKEN generated from BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD"
else
    echo "INFO: Site will work without authentication. No BASIC_AUTH_USERNAME or BASIC_AUTH_PASSWORD set."
    export AUTH_TOKEN=""
fi

# Replace environment variables in nginx config
envsubst '${AUTH_TOKEN}' < /etc/nginx/conf.d/default.conf > /tmp/default.conf
mv /tmp/default.conf /etc/nginx/conf.d/default.conf

# Execute the CMD
exec "$@"
