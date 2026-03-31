# Meal House - Project Status & Remaining Features Report

Based on a thorough investigation of the codebase (both frontend and backend), the core functionality for single-meal ordering has been largely established—including authentication, dynamic menu loading, cart checkouts, and basic order state transitions. 

However, several crucial modules across the **Admin**, **Mess Owner**, and **User** sides are missing, mocked, or require production wiring. Below is a detailed breakdown of the remaining work categorized by role:

---

## 🏗️ 1. Admin Side
The entire Admin console is currently a scaffold with mostly dummy endpoints, except for Pickup Points.
- **Pending Approvals & Verification**: The `AdminHomeScreen` shows "12 Vendors waiting" as a static stat. We need a backend route (`GET /api/messes/pending`) and a UI screen for the Admin to accept/reject new Mess Owner registrations.
- **Global Settlements & Payouts**: The `AdminProfileScreen` has a dummy button for "Global Settlements". A system is needed to aggregate all payments processed by Razorpay, deduct the platform commission, and establish a payout ledger for Mess Owners.
- **Role & Access Management**: Fully mock. Needs an endpoint to list all platform users and allow the Super Admin to flip boolean flags (e.g., `isManager`, `isDelivery`, `isBanned`).
- **Activity Logs & System Config**: Static buttons on the profile screen that need actual UI screens and backend metric generation.

## 👨‍🍳 2. Mess Owner Side
- **Analytics & Revenue Reports**: The `RevenueReportsScreen` and its internal `earnings_trend_chart_widget` are populated entirely with static arrays.
  - *Remaining Task*: Implement a backend aggregation route in `orderController.ts` to calculate actual earnings over date ranges (Today, This Week, This Month) based on `Delivered` orders, and stream it via Riverpod.
- **Pickup Point Distribution Generation**: The `PickupPointOrdersScreen` lists orders but has a `// TODO: Connect to distribution list generation API`.
  - *Remaining Task*: Build an algorithm that aggregates all pending orders by `pickupPointId`, so mess owners know exactly how many Thalis to send to bulk pickup hubs (like office gates or college campuses).

## 👤 3. User & Customer Side
- **Push Notifications & Live Sync**: The `NotificationsScreen` uses static arrays.
  - *Remaining Task*: Integrate Firebase Cloud Messaging (FCM) or WebSockets. When an Admin or Mess Owner taps "Ready" or "Delivered", it must push a real-time notification to the user's phone.
- **Review & Rating Engine**: Users can currently only order food.
  - *Remaining Task*: After an order is `Delivered`, the app should prompt a `RateReviewScreen`. The backend must calculate the new average rating and push this updated score to the `Mess` model dynamically so the "Mess Near You" UI reflects organic feedback.
- **Customer Support & Integrations**: `HelpSupportScreen` has empty TODOs for `url_launcher` intents.
  - *Remaining Task*: Implement real system intents to "Launch Email Client" or "Launch Phone Dialer", or integrate a real Customer Desk chatbot API.
- **Monthly Subscription / Thali Passes**: 
  - *Remaining Task*: The app is currently a single-checkout eCommerce model. Authentic mess businesses run on recurring 30-day "Tiffin passes". Adding a Subscription Model to the MongoDB schema and creating a recurring coupon/wallet flow is an important enhancement.

---

### 🔧 System-Wide Architecture Needs
- **Global State Finalization**: Several newer UI screens (Notifications, Profile Preferences, Admin Dashboard) contain `// TODO: Replace with Riverpod/Bloc`. They currently use `setState` arrays for prototyping. These must be replaced with Consumer/Ref architectures.
- **Hardware Permissions**: `location_permission_screen.dart` contains `// TODO: Replace with permission_handler`. Location access is somewhat supervised but not fully bulletproof across OS variants.

### Recommended Next Steps:
If you want to transition towards a launchable beta, the highest priorities are:
1. **Admin Approval Flow** (so real messes can securely onboard).
2. **Revenue Reports Aggregation API** (so messes can see their earnings).
3. **WebSockets/FCM Notifications** (so users know when to pick up their food).
