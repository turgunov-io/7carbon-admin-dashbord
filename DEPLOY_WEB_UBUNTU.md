# Deploy Flutter Web on Ubuntu (nginx)

This project builds a static Flutter Web bundle in `build/web`.

## 1) Build

```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.7carbon.uz
```

`API_BASE_URL` is optional — release builds already default to
`https://api.7carbon.uz` (see `lib/core/config/app_config.dart`). Pass it only
to point a build at a different backend.

### Optional: WebAssembly build (faster runtime)

```bash
flutter build web --wasm --release
```

This emits `main.dart.wasm` plus a `main.dart.js` fallback for browsers without
WasmGC. It requires the cross-origin isolation headers shown below. Verified
working for this project.

## 2) Upload build/web recursively

Copy the *contents* of `build/web` to your nginx web root.

```bash
rsync -av --delete build/web/ user@server:/var/www/dash.7carbon.uz/
```

Do not copy only top-level files; folders like `assets/`, `canvaskit/`,
`skwasm/` (wasm builds), and `icons/` are required.

## 3) nginx config

`/etc/nginx/sites-available/dash.7carbon.uz`

```nginx
server {
    listen 80;
    server_name dash.7carbon.uz;

    root /var/www/dash.7carbon.uz;
    index index.html;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    types {
        application/wasm wasm;
    }

    # ---- Compression -------------------------------------------------
    # Without this the browser downloads ~3.1 MB of main.dart.js instead
    # of ~0.9 MB. This is the single largest load-time win.
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/javascript
        application/javascript
        application/json
        application/wasm
        image/svg+xml
        font/ttf
        font/otf
        font/woff
        font/woff2;

    # If ngx_brotli is available, prefer it (~15-20% smaller than gzip):
    # brotli on;
    # brotli_comp_level 5;
    # brotli_types text/plain text/css application/javascript application/json
    #              application/wasm image/svg+xml font/woff2;

    # ---- Caching -----------------------------------------------------
    # Flutter web filenames are NOT content-hashed (main.dart.js keeps its
    # name across builds), so long immutable caching would pin users to a
    # stale app. Revalidate with ETag instead: a 304 costs ~200 bytes.
    etag on;
    add_header Cache-Control "public, max-age=0, must-revalidate" always;

    # index.html and the service worker must never be served from cache.
    location = /index.html {
        add_header Cache-Control "no-store" always;
    }

    location = /flutter_service_worker.js {
        add_header Cache-Control "no-store" always;
    }

    # ---- Security ----------------------------------------------------
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header X-Frame-Options "SAMEORIGIN" always;

    # Required only for the --wasm build (skwasm needs cross-origin isolation).
    # Enabling these blocks non-CORP cross-origin subresources, so add them
    # together with the wasm build, not before.
    # add_header Cross-Origin-Opener-Policy "same-origin" always;
    # add_header Cross-Origin-Embedder-Policy "require-corp" always;

    # ---- Routing -----------------------------------------------------
    # Flutter SPA fallback for app routes only.
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static folders must not fall back to index.html.
    location /assets/    { try_files $uri =404; }
    location /canvaskit/ { try_files $uri =404; }
    location /skwasm/    { try_files $uri =404; }
    location /icons/     { try_files $uri =404; }
}
```

Enable and reload:

```bash
sudo ln -sf /etc/nginx/sites-available/dash.7carbon.uz /etc/nginx/sites-enabled/dash.7carbon.uz
sudo nginx -t
sudo systemctl reload nginx
```

## 4) Verify response headers

```bash
curl -I -H 'Accept-Encoding: gzip' http://dash.7carbon.uz/main.dart.js
curl -I http://dash.7carbon.uz/canvaskit/canvaskit.js
curl -I http://dash.7carbon.uz/canvaskit/canvaskit.wasm
curl -I http://dash.7carbon.uz/assets/AssetManifest.bin.json
```

Expected:

- `main.dart.js` -> `200` + `application/javascript` + `Content-Encoding: gzip`
- `canvaskit.js` -> `200` + `application/javascript`
- `canvaskit.wasm` -> `200` + `application/wasm`
- `AssetManifest.bin.json` -> `200` + `application/json`

Confirm the transferred size of `main.dart.js` is ~0.9 MB, not ~3.1 MB. If it
is still 3.1 MB, gzip is not applying.

## 5) Clear browser service worker cache

After deploy, unregister old service worker in browser devtools and hard reload.
