# Meal House — Full Codebase & `lib/features` Architecture Review

**Document type:** Code review and migration blueprint  
**Scope:** Entire repository with emphasis on `lib/`, especially `lib/features/`  
**Method:** Structure inspection, import/route/API tracing, and cross-check against `pubspec.yaml`, `main.dart`, and DI (`service_locator.dart`).  
**Note (Flutter):** “Hooks” (React-style) are not used. The Dart/Flutter equivalent is **state management** (e.g. Provider, Riverpod, Bloc). This project is predominantly **StatefulWidget + local state**; **GetIt** is used only for auth and `ApiClient`.

---

## Table of contents

1. [Repository layout (top level)](#1-repository-layout-top-level)
2. [`lib/` structure overview](#2-lib-structure-overview)
3. [Feature modules — inventory & responsibilities](#3-feature-modules--inventory--responsibilities)
4. [Cross-cutting modules (`core`, `shared`)](#4-cross-cutting-modules-core-shared)
5. [Modular design assessment](#5-modular-design-assessment)
6. [Issues discovered](#6-issues-discovered)
7. [Routing review](#7-routing-review)
8. [API layer review](#8-api-layer-review)
9. [Recommended target architecture](#9-recommended-target-architecture)
10. [Refactoring plan (safe migration)](#10-refactoring-plan-safe-migration)
11. [Documentation drift](#11-documentation-drift)

---

## 1. Repository layout (top level)

Observed at project root (`meal_house/`):

| Area | Purpose |
|------|---------|
| **`lib/`** | Flutter application source (primary focus). |
| **`android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`** | Platform runners. |
| **`test/`** | Tests (`widget_test.dart` only at time of review). |
| **`assets/`**, **`stitch_assets/`** | Asset storage / design exports. |
| **`backend/`** | Server code (separate from Flutter `lib/`). |
| **`docs/`** | Project documentation (this file). |
| **`presentation/`** | **Legacy / broken** — contains `app_routes.dart` with **invalid Dart** (multiple `class AppRoutes` in one file) and paths that do not match `lib/features`. **Not** the active app module. |
| **`.env.*`**, **`scripts/`**, **`README*.md`** | Env samples, scripts, readme variants. |

**Count:** `lib/**/*.dart` — **152 files** under `lib/` (feature-heavy UI codebase).

---

## 2. `lib/` structure overview

### 2.1 Entry

| File | Role |
|------|------|
| **`main.dart`** | `WidgetsFlutterBinding`, `EnvManager.initialize()`, `initializeDependencies()`, `runApp(MealHouseApp)`. |
| **`MealHouseApp`** | `MaterialApp` with `theme`, **`home: WelcomeScreen()`** only — **no `routes` / `onGenerateRoute` / `initialRoute`**. |

### 2.2 `lib/core/`

| Path | Role |
|------|------|
| `config/app_config.dart` | Environment flag, **API base URL**, timeouts, logging. |
| `config/env_manager.dart`, `environment.dart` | Env loading. |
| `di/service_locator.dart` | **GetIt** registration: `ApiClient`, `AuthService`, auth repository + use cases. |
| `presentation/screens/developer_page.dart` | Dev shortcuts; imports **non-existent** user/mess-owner home paths (see §6). |

### 2.3 `lib/shared/`

| Path | Role |
|------|------|
| `api/api_client.dart` | **Dio** client: interceptors, token attach, **401 refresh**, generic HTTP helpers. |
| `constants/api_endpoints.dart` | REST path constants (`/api/v1/...`). |
| `constants/app_constants.dart` | Storage keys, UI constants. |
| `exceptions/app_exceptions.dart` | Mapped API errors. |
| `theme/app_theme.dart` | ThemeData. |
| `widgets/` | `custom_button`, `custom_text_field`; presentation `floating_bottom_nav_bar`. |
| `utils/`, `extensions/` | Validators, helpers, string/datetime extensions. |

### 2.4 Missing from `lib/` (referenced elsewhere or docs)

| Expected (from README / imports) | Status |
|----------------------------------|--------|
| **`lib/routes/`** | **Not present** — `README_ARCHITECTURE.md` describes it; code uses ad-hoc imports to `routes/app_routes.dart` **inside feature subtrees** that **do not exist**. |
| **`lib/services/`** (global) | **Not present** — only `features/auth/data/services/auth_service.dart`. |

---

## 3. Feature modules — inventory & responsibilities

Below, **“screen”** = primary UI route widget; **widgets** = local UI decomposition.

### 3.1 `features/auth/` (~13 files) — **clean architecture**

| Layer | Contents | Responsibility |
|-------|----------|------------------|
| **domain/** | `entities/user.dart`, `repositories/auth_repository.dart`, `usecases/*.dart` | Contracts, login/register/logout use cases. |
| **data/** | `services/auth_service.dart`, `repositories/auth_repository_impl.dart` | HTTP via `ApiClient` + `ApiEndpoints`; token persistence. |
| **presentation/screens/** | `welcome_screen`, `login_screen`, `registration_screen`, `otp_screen`, `forgot_password`, `reset_password` | Auth UI flows. |

**Assessment:** Isolated, testable, aligned with “features + services + domain” goals. **This should be the template** for other domains when you add real APIs.

---

### 3.2 `features/user/` — customer discovery & menus

| Subfolder | Files / role |
|-----------|----------------|
| **`home_screen/home_screen/`** | `home_screen.dart` + **widgets** (`home_*_widget.dart`): main customer shell, search, meal tabs, mess cards, bottom nav. |
| **`home_screen/mess_near_you_screen/`** | Nearby mess listing; navigates with **string routes** (e.g. `'/order-summary'`). |
| **`home_screen/recommended_for_you_screen/`** | Recommendations; similar navigation patterns. |
| **`mess_details/restaurant_detail_screen/`** | Mess detail + **widgets** (hero, filters, thalis, cart bar, actions). |
| **`mess_details/*_menu_screen/`** | `breakfast`, `lunch`, `dinner` menu flows. |
| **`mess_details/dish_detail_screen/`** | Dish detail → order path. |
| **`mess_details/weekly_menu_screen/`**, **`menu_status_screen/`** | Weekly menu and status UI. |

**Structure:** Screen-per-folder + `widgets/`. **Deep nesting** (`home_screen/home_screen/`) hurts discoverability.

---

### 3.3 `features/order/` — customer order lifecycle

| Screen folder | Role |
|---------------|------|
| `my_orders_screen/` | Hub + **widgets** (tabs, app bar, cards for active/upcoming/completed/cancelled). |
| `upcoming_orders_screen/`, `order_history_screen/`, `cancel_order_screen/` | Scheduling and history. |
| `order_summary_screen/`, `order_status_screen/`, `order_meal_screen/` | Checkout and status. |
| `track_order_screen/` | Large tracking UI (~1000+ lines in file — maintainability risk). |
| `skip_meal_screen/` | Skip flow. |

---

### 3.4 `features/wallet/`

| Screen | Role |
|--------|------|
| `my_wallet_screen.dart` | Balance, actions, navigation to recharge/history. |
| `recharge_wallet_screen.dart` | Top-up UI. |
| `transaction_history_screen.dart` | List/history. |

---

### 3.5 `features/profile_screen/` — **customer account** (naming caveat)

| Screen | Role |
|--------|------|
| `profile_screen/` | Profile hub. |
| `settings_screen/` | Settings entry. |
| `edit_profile_screen/` | Edit profile. |
| `saved_locations_screen/` | Saved addresses (large file). |
| `pickup_preferences_screen/` | Pickup preferences. |

**Caveat:** Name **`profile_screen`** as a **feature folder** collides conceptually with **`mess_owner/profile_screen/`**.

---

### 3.6 `features/notifications/`

| Area | Role |
|------|------|
| `notifications_screen/` + `widgets/` | List, filters, app bar, bottom nav. |
| `notification_settings_screen/` | Settings. |

---

### 3.7 `features/settings/` — help & support

| Screen | Role |
|--------|------|
| `help_support_screen/` + `widgets/` | FAQ entry, contact, common issues, logout sheet. |
| `faq_detail_screen/` | FAQ detail. |
| `report_problem_screen/` | Issue reporting. |

---

### 3.8 `features/location/`

| Screen | Role |
|--------|------|
| `location_permission_screen/` + `widgets/` | Permission onboarding. |
| `location_selection_screen/` + `widgets/` | Search / map / chips. |
| `pickup_point_selection_screen/` + `widgets/` | Pickup selection. |

---

### 3.9 `features/review_screen/`

| Screen | Role |
|--------|------|
| `rate_review_screen/` | Post-delivery rating. |
| `review_submitted_screen/` | Confirmation. |

---

### 3.10 `features/mess_owner/` — largest feature area

| Sub-area | Role |
|----------|------|
| **`mess_profile/`** | Owner onboarding: `setup_mess_screen`, `mess_details_screen` (+ widgets), `upload_mess_photos_screen`, `mess_location_screen`, `operating_hours_screen`, `mess_profile_ready_screen`, **`dashboard_screen`**. |
| **`mess_orders/`** | `orders_screen`, `order_details_screen`, `todays_orders_screen`, `office_gate_pickup_screen`, `update_order_status_screen`. |
| **`mess_orders/pickup_point_orders/`** | **`PickupPointOrdersScreen`** (animations, shared widgets) — imports **`../../theme/app_theme.dart`**, **`../../widgets/app_navigation.dart`** — **those paths do not exist under `mess_owner/`** (broken relative imports). |
| **`mess_orders/pickup_point_orders_screen/`** | **Second `PickupPointOrdersScreen`** — simpler stub-style UI, **duplicate class name** if both are ever imported together. |
| **`menu/`** | `todays_menu_screen`, `add_menu_item_screen`. |
| **Top-level screens** | `earnings_screen`, `revenue_reports_screen` (+ chart widgets), `menu_history_screen`, `past_order_history_screen`, **`profile_screen`** (owner). |

---

### 3.11 `features/admin/`

| File | Role |
|------|------|
| `presentation/screens/admin_home.dart` | Placeholder admin shell. |

---

### 3.12 `features/widgets/` — **shared UI misplaced**

| Widget file | Role |
|-------------|------|
| `custom_error_widget`, `empty_state_widget`, `loading_skeleton_widget`, `status_badge_widget`, `custom_image_widget`, `custom_icon_widget` | App-wide UI helpers. |

**Assessment:** These belong under **`lib/shared/widgets/`** (or `lib/core/ui/`), not under **`features/`**, to keep features **product-scoped**.

---

## 4. Cross-cutting modules (`core`, `shared`)

- **`core`:** Configuration and DI only; no feature business logic.  
- **`shared`:** True cross-cutting: HTTP, theme, validators, generic widgets.  
- **Dependency rule (target):** `features/*` → may depend on `shared` and `core`; **not** the reverse. **Avoid** `features/A` importing `features/B` screens directly — prefer **router**, **events**, or **shared contracts**.

---

## 5. Modular design assessment

| Criterion | Finding |
|-----------|---------|
| **Feature isolation** | **Weak** outside `auth/`. Many screens are self-contained files with **no domain/data layer**. |
| **Consistency** | **Low** — only `auth/` uses `data/domain/presentation`; others use **folder-per-screen**. |
| **Reusable logic** | **Duplication risk** — e.g. two **`PickupPointOrdersScreen`** implementations; repeated bottom-nav patterns across notifications/orders/help. |
| **State management** | Mostly **setState**; TODOs mention Riverpod/Bloc in places; **no** unified pattern in `pubspec` beyond **GetIt**. |
| **Tests** | Minimal (`test/widget_test.dart`); features **not** covered by unit/widget tests in tree. |

---

## 6. Issues discovered

### 6.1 Navigation — root not wired

- **`main.dart`** does not pass **`routes`** or **`onGenerateRoute`** to `MaterialApp`.
- Many files call **`Navigator.pushNamed(...)`** expecting a **global** route table — **none is registered** at the root. Runtime navigation to named routes will fail unless a parent `Navigator` provides them (currently **none**).

### 6.2 Missing / broken imports (verified)

| Symptom | Evidence |
|---------|----------|
| **Welcome / dev entry** | `welcome_screen.dart` imports `../../../user/presentation/screens/home_screen.dart` and `../../../mess_owner/presentation/screens/mess_owner_home.dart` — **those files do not exist** (actual user home: `features/user/home_screen/home_screen/home_screen.dart`). |
| **Feature-local routes** | Many files: `import '.../routes/app_routes.dart'` — **no** such file under the resolved `lib/features/.../routes/` paths in the repo. |
| **Barrel export** | Multiple files: `import '.../core/app_export.dart'` — **file does not exist** under the referenced relative paths. |
| **Mess owner pickup (full)** | `pickup_point_orders/pickup_point_orders_screen.dart` imports `mess_owner/theme/app_theme.dart` and `mess_owner/widgets/app_navigation.dart` — **not present**. |

### 6.3 Orphan `presentation/app_routes.dart` (repo root)

- Contains **multiple `class AppRoutes` definitions** in a **single file** → **invalid Dart**.
- Imports `../presentation/...` layouts that **do not mirror** `lib/features`.
- **Must not** be used as the canonical router; treat as **scrap** or delete after replacement.

### 6.4 Duplicate screen implementations

- **`mess_owner/mess_orders/pickup_point_orders/pickup_point_orders_screen.dart`** vs **`mess_owner/mess_orders/pickup_point_orders_screen/pickup_point_orders_screen.dart`**: same **class name**, different implementations — **merge or delete** one; fix imports and routes accordingly.

### 6.5 Dependency / tooling

- **`package:sizer/sizer.dart`** is imported from many screens (e.g. help, profile, notifications), but **`sizer` is not listed in `pubspec.yaml`** and **does not appear in `pubspec.lock`** — the project **cannot resolve** those imports until `sizer` is added (or imports replaced with `MediaQuery`/layout builders).

### 6.6 API configuration consistency

- **`AppConfig.apiBaseUrl`** (e.g. `http://10.0.2.2:5000/api/v1`) includes **`/api/v1`**.  
- **`ApiEndpoints`** paths also start with **`/api/v1/...`**.  
- **`AuthService`** calls `_apiClient.post(ApiEndpoints.login, ...)` → risk of **duplicated path segment** depending on Dio URI resolution. **`ApiClient._refreshToken`** uses `'/auth/refresh'` (relative segment) while **`ApiEndpoints.refreshToken`** is `'/api/v1/auth/refresh'` — **inconsistent** with each other and with the `ApiEndpoints` pattern.  
- **Action:** Define a single rule: **either** base URL = **origin only** and paths = full `/api/v1/...`, **or** base = `.../api/v1` and paths = `/auth/login`, etc. Use **`ApiEndpoints` everywhere** in services.

### 6.7 Documentation / analysis artifacts

- **`README_ARCHITECTURE.md`** describes `lib/routes/`, `lib/services/`, and a **fully** clean `features/user` layout — **does not match** the current tree.  
- **`analyze_results.txt`** references paths like `lib/features/user/presentation/screens/...` — **stale** vs current `lib/features/user/...` layout.

---

## 7. Routing review

### 7.1 Current patterns in code

- **`AppRoutes.*` constants** — imported from **missing** `routes/app_routes.dart` files.  
- **Raw strings** — e.g. `'/order-summary'`, `'/recommended-for-you'`, `'/add-menu-item-screen'`, `'/mess-location-screen'`, `'/my-wallet-screen'`, `'/faq-detail-screen'`.  
- **Imperative push** — `Navigator.push` with `MaterialPageRoute` from **`WelcomeScreen`** for role shortcuts (works **without** named routes).

### 7.2 Risks

- **No single registry** of route names → **drift** and **collisions** (e.g. multiple features defining `profileScreen`).  
- **No deep linking** / web path strategy.  
- **No guard** for auth or role (user vs mess owner vs admin).

### 7.3 Recommendations

1. **Single router module** under `lib/app/router/` or `lib/core/router/`:  
   - Option A: **`go_router`** — typed routes, nested navigation, web URLs.  
   - Option B: **`MaterialApp.routes`** + **one** `Map<String, WidgetBuilder>` built from a **single** `AppRoutes` class — no duplicate class names.  
2. **Prefix route constants** by role: e.g. `UserRoutes.profile`, `OwnerRoutes.profile`, `AdminRoutes.dashboard`.  
3. **Eliminate raw strings** in `pushNamed` — use constants only.  
4. **Map every screen** used in production to **exactly one** route entry.

---

## 8. API layer review

### 8.1 What exists today

| Component | Assessment |
|-----------|------------|
| **`ApiClient`** | Strong foundation: timeouts, JSON headers, **Bearer** token, **401** refresh attempt, generic verbs, upload/download. |
| **`ApiEndpoints`** | Central list of REST paths — **good**, subject to base URL normalization (§6.6). |
| **`AuthService` + repository + use cases** | **Good** separation; uses DI. |
| **Other domains** | **No** `OrderService`, `WalletService`, etc. in `service_locator.dart` — UI is largely **disconnected** from backend for non-auth flows (by current registration list). |

### 8.2 Recommended API organization

```
lib/shared/api/
  api_client.dart          # keep
  (optional) interceptors/

lib/features/<feature>/data/
  datasources/<feature>_remote_datasource.dart   # uses ApiClient + ApiEndpoints only
  models/                                      # DTOs (json_serializable optional)
  repositories/<feature>_repository_impl.dart

lib/core/di/service_locator.dart
  # register datasources, repositories, use cases per feature
```

- **Do not** scatter raw paths in widgets — only in **datasources** or **`ApiEndpoints`**.  
- Map **errors** through existing **`ExceptionHandler`** / `app_exceptions.dart`.

---

## 9. Recommended target architecture

Flutter “components” ≈ **widgets**; “hooks” ≈ **providers / notifiers / Bloc** (pick one stack). Suggested layout:

```
lib/
├── app/
│   ├── app.dart                 # MaterialApp.router or MaterialApp + routes
│   └── router/
│       ├── app_router.dart      # go_router config OR route table export
│       └── route_names.dart     # all path strings / typed args
├── core/
│   ├── config/
│   ├── di/
│   ├── error/                   # optional global error mapper
│   └── utils/
├── shared/
│   ├── api/
│   ├── constants/               # app_constants, api_endpoints
│   ├── theme/
│   ├── widgets/                 # + migrate from features/widgets
│   ├── extensions/
│   └── utils/
└── features/
    ├── auth/                    # data / domain / presentation (keep)
    ├── account/                 # rename from profile_screen (customer)
    ├── user_home/               # flatten user/home_screen nesting
    ├── mess_details/
    ├── orders/
    ├── wallet/
    ├── notifications/
    ├── location_onboarding/
    ├── support/                 # merge settings/help/report if desired
    ├── reviews/
    ├── mess_owner/              # sub-features: dashboard, orders, menu, reporting, owner_profile
    └── admin/
```

**Types:** Prefer **`domain/entities`** + **`data/models`** per feature; shared DTOs only in `shared/` if truly cross-feature.

---

## 10. Refactoring plan (safe migration)

### Phase 1 — Restore correctness (blocking)

1. Fix **`welcome_screen.dart`** and **`developer_page.dart`** imports to **existing** files; add a thin **`MessOwnerHomeScreen`** (or navigate to **`DashboardScreen`** / **`SetupMessScreen`** per product rules).  
2. Add **`lib/core/router/`** (or `lib/app/router/`) with **one** `AppRoutes` / `RouteNames` and **wire** `MaterialApp` (`routes` or `routerConfig`).  
3. Remove or stop using **root `presentation/app_routes.dart`**.  
4. Add missing **`sizer`** to **`pubspec.yaml`** **or** remove all `sizer` imports and replace with Flutter layout.  
5. Normalize **`AppConfig.apiBaseUrl`** vs **`ApiEndpoints`** and fix **`_refreshToken`** to use **`ApiEndpoints.refreshToken`** (after path rules are fixed).  
6. Resolve **`pickup_point_orders`** duplicate screens and **broken** `theme`/`app_navigation` imports.

### Phase 2 — Routing quality

1. Replace **string** `pushNamed` calls with **central constants**.  
2. Introduce **role-based** route branches (user / owner / admin).  
3. Optional: migrate to **`go_router`** for maintainability and web.

### Phase 3 — Structure & shared code

1. Move **`features/widgets`** → **`shared/widgets`**.  
2. Rename **`features/profile_screen`** → **`account`** (or `customer_profile`).  
3. Flatten **`user/home_screen/home_screen/`** to **`user/presentation/screens/home_screen.dart`** (or `user_home/screens/...`).

### Phase 4 — API & DI expansion

1. For each backend area (orders, wallet, mess, notifications), add **remote datasource → repository → use case** as needed.  
2. Register in **`service_locator.dart`**.  
3. Add **integration tests** or manual QA checklist per flow.

### Phase 5 — State management (optional but scalable)

1. Choose **one** of Provider / Riverpod / Bloc.  
2. Move async logic out of **State** classes into **notifiers/blocs**.

---

## 11. Documentation drift

| Document | Issue |
|----------|--------|
| **`README_ARCHITECTURE.md`** | Describes `lib/routes/`, `lib/services/`, and clean `features/user` — **not** reflected in repo. **Update** after refactor or add banner “aspirational / outdated”. |
| **`analyze_results.txt`** | Points to **old** `user/presentation/...` paths — **regenerate** after structure stabilizes. |

---

## Summary

The codebase is a **UI-rich Flutter app** with **one well-structured feature (`auth`)** and **extensive screen-level folders** elsewhere. **Critical gaps** are: **root navigation not registered**, **missing route and export files**, **broken entrypoint imports**, **duplicate `PickupPointOrdersScreen`**, **likely missing `sizer` dependency**, and **API base path inconsistency**. Addressing **Phase 1** first yields a **compilable, navigable** app; subsequent phases improve **modularity**, **testability**, and **backend integration** in line with modern scalable Flutter practice.

---

*Last updated from repository analysis: `lib/` file count 152 `*.dart`; `pubspec.yaml` dependencies as listed in repo.*
