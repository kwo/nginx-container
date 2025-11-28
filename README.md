# Webserver Image

Using NGINX to serve static files to be fronted by a CDN. The CDN is the only client that will have access and will only allow access if authorized by a special header.

## Configuration

This NGINX container is configured with:

- **CDN Authorization**: Requests must include HTTP Basic authentication via the `Authorization` header matching the `AUTH_TOKEN` environment variable
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

## Generating Basic Auth Credentials

To generate the value for `AUTH_TOKEN`, you need to create a Base64-encoded string in the format `Basic <base64(username:password)>`.

Using command line:
```bash
echo -n "username:password" | base64
# Output: dXNlcm5hbWU6cGFzc3dvcmQ=

# The full value for AUTH_TOKEN would be:
# Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

Or generate it in one command:
```bash
echo "Basic $(echo -n 'username:password' | base64)"
```

**Example:**
- Username: `cdn`
- Password: `secret123`
- Command: `echo -n "cdn:secret123" | base64`
- Result: `Y2RuOnNlY3JldDEyMw==`
- Full auth header: `Basic Y2RuOnNlY3JldDEyMw==`

## Usage

Build the image:
```bash
podman build -t k22os.de/nginx .
```

Run the container:
```bash
podman run -d \
  -p 80:80 \
  -e AUTH_TOKEN="Basic Y2RuOnNlY3JldDEyMw==" \
  -v /path/to/html:/data/html \
  -v /path/to/logs:/data/logs \
  -v /path/to/run:/data/run \
  k22os.de/nginx
```

Or mount the entire `/data` directory:
```bash
podman run -ti --rm \
  -p 8080:80 \
  -e AUTH_TOKEN="Basic Y2RuOnNlY3JldDEyMw==" \
  -v $HOME/Public/nginx-data:/data \
  k22os.de/nginx
```

## Required Files

Place the following files in `/data/html`:
- `index.html` - Default index page
- `401.html` - Unauthorized error page
- `403.html` - Forbidden error page
- `404.html` - Not found error page
- `50x.html` - Server error page
