# `lib/` folder layout (Meal House)

This document reflects the **intended structure** after moving shared UI out of `features/`.

## Top level

| Path | Purpose |
|------|---------|
| **`lib/main.dart`** | App entry: `MaterialApp`, theme, `initialRoute`, `routes`. |
| **`lib/core/`** | App-wide non-UI: config, DI, barrel `app_export.dart`, **router** (`core/router/app_routes.dart`). |
| **`lib/features/`** | **Product features** only (screens + feature-local widgets). No generic reusable widgets here. |
| **`lib/shared/`** | **Cross-cutting**: API client, constants, theme, exceptions, utils, extensions, **all reusable widgets**. |

## `lib/core/`

- `config/` — `AppConfig`, env, `EnvManager`
- `di/` — `service_locator.dart` (GetIt)
- `router/` — `app_routes.dart` (route names + `AppRoutes.routes` map)
- `app_export.dart` — optional barrel: `material`, `services`, `AppTheme`, `AppRoutes`
- `presentation/screens/` — e.g. `developer_page.dart`

## `lib/shared/`

- `api/` — `api_client.dart`
- `constants/` — `app_constants.dart`, `api_endpoints.dart`
- `exceptions/`, `extensions/`, `utils/`
- `theme/` — `app_theme.dart`
- `widgets/` — **all shared components**, including:
  - `custom_button.dart`, `custom_text_field.dart`
  - `custom_image_widget.dart`, `custom_error_widget.dart`, `custom_icon_widget.dart`
  - `status_badge_widget.dart`, `empty_state_widget.dart`, `loading_skeleton_widget.dart` (+ `OrderCardSkeletonWidget`)
  - `mess_owner_app_navigation.dart`, `floating_bottom_nav_bar.dart`

## `lib/features/<feature>/`

- One folder per capability (`auth`, `user`, `order`, `mess_owner`, `location`, …).
- Screens live in `*_screen/` folders with local `widgets/` where needed.
- Feature-specific navigation helpers stay under that feature (e.g. `location/widgets/location_flow_navigation.dart`).

## Import rule

- Prefer **`package:meal_house/...`** for anything outside the current file’s package subtree.
- Shared UI: `import 'package:meal_house/shared/widgets/...';`
- Routes: `import 'package:meal_house/core/router/app_routes.dart';`
