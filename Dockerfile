FROM alpine:3.22.2

# Set environment variables for basic auth (to be used by entrypoint)
ENV BASIC_AUTH_USERNAME=""
ENV BASIC_AUTH_PASSWORD=""

# Install nginx via package manager
RUN apk add --no-cache nginx gettext && \
  mkdir -p /run/nginx && \
  mkdir -p /var/tmp/nginx

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy and set up entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Mount data directory as volume
VOLUME /data

EXPOSE 80

# Set entrypoint to run before CMD
ENTRYPOINT ["/docker-entrypoint.sh"]

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
