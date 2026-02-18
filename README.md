# Carbon Admin (Flutter Web)

Production-ready Flutter Web admin dashboard for Go backend.

## Stack

- Flutter stable, Dart 3+
- State management: `flutter_riverpod`
- HTTP: `dio`
- File upload: `file_picker`
- Routing: `go_router`
- Models: `json_serializable`
- UI: Material 3, desktop-first adaptive layout

## Backend Contract

- Base URL (default): `http://localhost:7777`
- Optional token auth via `ADMIN_TOKEN` (`Authorization: Bearer <token>`)
- API response envelope:
  - success: `{ "status": "success", "data": ... }`
  - error: `{ "status": "error", "message": "..." }`
- Storage API:
  - `POST /admin/storage/upload`
  - `GET /admin/storage/files`
  - `DELETE /admin/storage/file`

Base URL is configurable with:

```bash
flutter run -d chrome --no-web-resources-cdn --dart-define=API_BASE_URL=http://localhost:7777

# with token
flutter run -d chrome --no-web-resources-cdn --dart-define=API_BASE_URL=http://localhost:7777 --dart-define=ADMIN_TOKEN=your_token
```

## Run

1. Install dependencies:

```bash
flutter pub get
```

2. Generate JSON serializers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

3. Run Web app:

```bash
flutter run -d chrome --no-web-resources-cdn --dart-define=API_BASE_URL=http://localhost:7777

# with token
flutter run -d chrome --no-web-resources-cdn --dart-define=API_BASE_URL=http://localhost:7777 --dart-define=ADMIN_TOKEN=your_token
```

If your network blocks `fonts.gstatic.com` or Google CDN domains, keep `--no-web-resources-cdn`.

## CRUD Entities

The dashboard implements List/Create/Edit/Delete/Details for:

- `/admin/banners`
- `/admin/contact`
- `/admin/contact_page`
- `/admin/about_page`
- `/admin/about_metrics`
- `/admin/about_sections`
- `/admin/partners`
- `/admin/tuning`
- `/admin/service_offerings`
- `/admin/privacy_sections`
- `/admin/portfolio_items`
- `/admin/work_post`
- `/admin/blog_posts`
- `/admin/consultations`

Each entity page includes:

- searchable/sortable paginated table
- refresh button
- loading/empty/error states
- create dialog (`POST`)
- edit dialog (`PUT` with `PATCH` fallback)
- delete confirmation (`DELETE`)
- details dialog (`GET /admin/<table>/<id>`)

## Validation Rules

UI enforces required fields for:

- `banners`: `section`, `title`, `image_url`
- `partners`: `logo_url`
- `service_offerings`: `service_type`, `title`
- `privacy_sections`: `title`, `description`
- `portfolio_items`: `title`, `image_url`
- `about_metrics`: `metric_key`, `metric_value`, `metric_label`
- `about_sections`: `section_key`, `title`, `description`
- `work_post` / `blog_posts`: `title_model`
- `consultations`: `first_name`, `last_name`, `phone`, `service_type`

## Special Fields

Array/JSON editors implemented for:

- `tuning.full_image_url`
- `service_offerings.gallery_images`
- `work_post.work_list`
- `work_post.gallery_images`
- `blog_posts.work_list`
- `blog_posts.gallery_images`

Nullable values are rendered as `—`.

## Dashboard

- Sidebar navigation for all entities
- Main page with record count cards for all entities
- Quick actions:
  - `Create banner`
  - `Create partner`
  - `Create service offering`

## Storage

- Dedicated `Storage` page in sidebar
- Bucket/prefix filters
- `Load all buckets` mode (`GET /admin/storage/files?all=true&limit=50`)
- Grouped rendering in all-mode: `bucket -> files table`
- Single-bucket mode preserved
- Upload file with progress
- File table, copy public URL, delete file
- Upload integration in CRUD forms:
  - `banners.image_url`
  - `partners.logo_url`
  - `portfolio_items.image_url`
  - `tuning.card_image_url`
  - `tuning.full_image_url[]`
  - `service_offerings.gallery_images[]`
  - `work_post.gallery_images[]`

Array URL manager supports add/remove/reorder and inserting URL after upload.

## Architecture (Feature-first)

```text
lib/
  core/
    config/
    network/
    routing/
    theme/
    ui/
  features/
    admin/
      application/
      data/
      domain/
      models/
      ui/
    dashboard/
      application/
      domain/
      ui/
```

## Key Files

- App entry: `lib/main.dart`
- Root app: `lib/app.dart`
- Router: `lib/core/routing/app_router.dart`
- Routes/nav: `lib/core/routing/app_route.dart`
- API client (Dio + envelope handling): `lib/core/network/api_client.dart`
- Error handling: `lib/core/network/api_error.dart`
- Entity registry/config: `lib/features/admin/domain/admin_entity_registry.dart`
- Generic CRUD repository: `lib/features/admin/data/admin_repository.dart`
- Generic CRUD page: `lib/features/admin/ui/admin_entity_page.dart`
