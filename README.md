# Webserver Image

Using NGINX to serve static files to be fronted by a CDN. The CDN is the only client that will have access and will only allow access if authorized by a basic auth header.

## Configuration

This NGINX container is configured with:

- **CDN Authorization**: Requests must include HTTP Basic authentication via the `Authorization` header. Authentication is configured using `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` environment variables
- **Custom Error Pages**: 401, 403, 404, and 50x errors are served from custom HTML files
- **Cache Control**:
  - Static files (HTML): 60 seconds
  - Error pages: no caching (private, max-age=0)
  - CSS/JS files: 30 days (2592000 seconds)
  - Images (jpg, png, gif, ico, svg): 30 days (2592000 seconds)
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection
- **Gzip Compression**: Enabled for common text and media types

## Volume Structure

The container uses a single `/data` volume with three subdirectories:

- **`/data/html`** - Static files and web content (served from this directory)
- **`/data/logs`** - NGINX access and error logs
- **`/data/run`** - NGINX PID file

## Authentication

The container requires two environment variables for Basic Authentication:

- `BASIC_AUTH_USERNAME` - The username for authentication
- `BASIC_AUTH_PASSWORD` - The password for authentication

The container's entrypoint script automatically generates the Base64-encoded Basic Auth token from these credentials at startup. The token is created in the format `Basic <base64(username:password)>` and configured in the NGINX server.

## Usage

Build the image:
```bash
podman build -t nginx .
```

Run the container:
```bash
podman run -d \
  -p 8080:80 \
  -e BASIC_AUTH_USERNAME="cdn" \
  -e BASIC_AUTH_PASSWORD="secret123" \
  -v /path/to/html:/data/html \
  -v /path/to/logs:/data/logs \
  -v /path/to/run:/data/run \
  nginx
```

Or mount the entire `/data` directory:
```bash
podman run -ti --rm \
  -p 8080:80 \
  -e BASIC_AUTH_USERNAME="cdn" \
  -e BASIC_AUTH_PASSWORD="secret123" \
  -v $HOME/Public/nginx-data:/data \
  nginx
```

## Required Files

Place the following files in `/data/html`:
- `index.html` - Default index page
- `401.html` - Unauthorized error page
- `403.html` - Forbidden error page
- `404.html` - Not found error page
- `50x.html` - Server error page
