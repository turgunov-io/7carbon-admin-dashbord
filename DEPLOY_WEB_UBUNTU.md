# Deploy Flutter Web on Ubuntu (nginx)

This project builds a static Flutter Web bundle in `build/web`.

## 1) Build

```bash
flutter build web --release
```

## 2) Upload build/web recursively

Copy the *contents* of `build/web` to your nginx web root.

```bash
rsync -av --delete build/web/ user@server:/var/www/dash.7carbon.uz/
```

Do not copy only top-level files; folders like `assets/`, `canvaskit/`, and `icons/` are required.

## 3) nginx config (example)

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

    # Flutter SPA fallback for app routes only.
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static folders must not fall back to index.html.
    location /assets/ {
        try_files $uri =404;
    }

    location /canvaskit/ {
        try_files $uri =404;
    }

    location /icons/ {
        try_files $uri =404;
    }
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
curl -I http://dash.7carbon.uz/main.dart.js
curl -I http://dash.7carbon.uz/canvaskit/canvaskit.js
curl -I http://dash.7carbon.uz/canvaskit/canvaskit.wasm
curl -I http://dash.7carbon.uz/assets/AssetManifest.bin.json
```

Expected:

- `main.dart.js` -> `200` + `application/javascript`
- `canvaskit.js` -> `200` + `application/javascript`
- `canvaskit.wasm` -> `200` + `application/wasm`
- `AssetManifest.bin.json` -> `200` + `application/json`

## 5) Clear browser service worker cache

After deploy, unregister old service worker in browser devtools and hard reload.
