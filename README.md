# Webserver Image

Using NGINX to serve static files to be fronted by a CDN. The CDN is the only client that will have access and will only allow access if authorized by a basic auth header.

## Configuration

This NGINX container is configured with:

- **CDN Authorization**: Requests must include HTTP Basic authentication via the `Authorization` header. Authentication is configured by mounting an htpasswd file to `/etc/nginx/htpasswd` (optional - if not provided, authentication is disabled)
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

This container uses HTTP Basic Authentication via an htpasswd file. The authentication is optional:

- **With authentication**: Mount an htpasswd file to `/etc/nginx/htpasswd` in the container
- **Without authentication**: If no htpasswd file is present, authentication is disabled

The entrypoint script automatically detects the presence of the htpasswd file and configures NGINX accordingly.

## Build

Build the image:
```bash
podman build -t nginx .
```

## Preparation

### Required Files

Create the following difrectories in the data directory:
```bash
mkdir -p /data/{html,logs,run}
```

Place the following files in `/data/html`:
- `index.html` - Default index page
- `401.html` - Unauthorized error page
- `403.html` - Forbidden error page
- `404.html` - Not found error page
- `50x.html` - Server error page

### Creating an htpasswd file

**Using Docker/Podman (recommended - no local tools required):**
```bash
# Using Alpine httpd image with current directory mounted
podman run --rm -it -v $(pwd):/work -w /work httpd:alpine sh -c "htpasswd -cB htpasswd cdn"

# Add additional users (without -c flag)
podman run --rm -it -v $(pwd):/work -w /work httpd:alpine sh -c "htpasswd -B htpasswd anotheruser"
```

## Usage

### Running with Authentication

```bash
podman run --rm -ti \
  -p 8080:80 \
  -v $(pwd)/htpasswd:/etc/nginx/htpasswd:ro \
  -v $HOME/Public/nginx-data:/data \
  nginx
```

### Running without Authentication

```bash
podman run --rm -ti \
  -p 8080:80 \
  -v $HOME/Public/nginx-data:/data \
  nginx
```
