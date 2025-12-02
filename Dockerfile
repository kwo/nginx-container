FROM alpine:3.22.2

# Install nginx via package manager
RUN apk add --no-cache nginx \
  && mkdir -p /data/html

COPY nginx.conf   /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/http.d/default.conf
COPY html/4*.html /var/lib/nginx/html
COPY html/5*.html /var/lib/nginx/html
COPY html/index.html /data/html
COPY entrypoint.sh /entrypoint.sh

# Mount data directory as volume
VOLUME /data

EXPOSE 80

# Set entrypoint to run before CMD
ENTRYPOINT ["/entrypoint.sh"]

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
