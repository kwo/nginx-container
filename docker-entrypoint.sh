#!/bin/sh
set -e

# Check for htpasswd file and configure auth_basic directive
if [ -f /etc/nginx/htpasswd ]; then
    echo "restricting with http basic auth"
    sed -i 's/auth_basic[[:space:]]*off;/auth_basic "CDN";/' /etc/nginx/http.d/default.conf
fi

# Execute the CMD
exec "$@"
