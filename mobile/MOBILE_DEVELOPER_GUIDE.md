# SnapTicket Mobile Developer Guide & Panel Defense Manual

---

## 1. Project Purpose

**SnapTicket** is a smart, end-to-end event ticket reservation platform consisting of a React web discovery portal, an Express.js + MongoDB backend, and a dedicated Flutter mobile companion application. The system eliminates ticket booking friction by offering live seat inventory tracking, instant reservation confirmation, and verifiable digital ticket passes.

---

## 2. Why Does SnapTicket Need a Mobile App? (Web vs Mobile Product Philosophy)

> [!IMPORTANT]
> **Panel Question**: *"Why do you need a mobile app when the same ticket booking can be done through the website?"*

### Honest Product Distinction:

| Dimension | React Web Application | Flutter Mobile Companion Application |
| :--- | :--- | :--- |
| **Primary Goal** | **Discovery & Broad Exploration** | **Personal Ticket Management & Attendance** |
| **User Mindset** | Browsing on desktop/laptop, comparing events, researching schedules, multi-tab exploration. | On the move, arriving at the venue, checking ticket status, entry gate admission. |
| **Key Hero Feature**| Multi-event filter matrices, rich description layouts, organizer landing pages. | **"Your Next Event" dashboard card**, **Verifiable Digital Ticket with QR pass**, 1-tap admission. |
| **Offline Need** | Online only. | **Offline Ticket Pass**: Displays confirmed ticket pass even if venue cell signal drops. |
| **Speed to Ticket** | Requires navigation through browser, login, and bookmarks. | Instant app launch straight to digital pass in under 2 seconds. |

The mobile application is **NOT** a miniaturized copy of the website. It acts as the user's **Personal Ticket Wallet & Day-of-Event Companion**.

---

## 3. Why Flutter?

1. **Cross-Platform Single Codebase**: Delivers native 60–120 FPS performance on both Android and iOS from a single Dart codebase.
2. **Material 3 & Glassmorphism**: Flutter's hardware-accelerated Skia/Impeller engine renders smooth `BackdropFilter` blurs and gradients seamlessly without native bridge bottlenecks.
3. **Sound Null Safety & Strong Typing**: Eliminates common runtime crashes when parsing nested JSON responses from REST backends.
4. **Fast Prototyping (Hot Reload)**: Enabled rapid iteration of the entire mobile UI during the hackathon.

*Fair Comparison*: React Native is also a viable choice for teams with deep web React expertise; however, Flutter was selected here for its high-performance compiled graphics engine, built-in Material 3 widgets, and self-contained rendering pipeline.

---

## 4. Architecture

### Full-Stack Architecture

```
                       SnapTicket Backend
                      (Node.js + Express)
                     Port: 5000 / MongoDB
                              │
             ┌────────────────┴────────────────┐
             │ REST API                        │ REST API
             ▼                                 ▼
       React Web Client               Flutter Mobile Client
    (Discovery & Booking)           (Ticket Companion & Passes)
                                               │
                                               ▼
                                      ApiService Interface
                                               │
                                 ┌─────────────┴─────────────┐
                                 ▼                           ▼
                        RealApiService (HTTP)       MockApiService (Active)
```

---

## 5. Current Folder Structure

```
mobile/
├── lib/
│   ├── main.dart                      # MultiProvider bootstrap, theme routing, MaterialApp
│   │
│   ├── models/                        # Typed data contracts
│   │   ├── user.dart                  # User entity (_id, name, email, avatar, interests)
│   │   ├── event.dart                 # Event entity (_id, name, category, seats, price, image)
│   │   └── booking.dart               # Booking entity & qrPayload generator
│   │
│   ├── services/                      # Data layer & Networking
│   │   ├── api_service.dart           # Abstract interface & Factory provider
│   │   ├── mock_api_service.dart      # Stateful mock engine with seed data & seat sync
│   │   └── real_api_service.dart      # REST HTTP client matching Express routes
│   │
│   ├── providers/                     # Reactive state management (ChangeNotifier)
│   │   ├── theme_provider.dart        # ThemeMode (System/Light/Dark) + SharedPreferences
│   │   ├── user_provider.dart         # Active user selection + SharedPreferences
│   │   ├── event_provider.dart        # Event catalogue, search, category filter, seat sync
│   │   └── booking_provider.dart      # Booking creation, history list, and cancellation
│   │
│   ├── screens/                       # Presentation screens
│   │   ├── main_navigation_screen.dart# Floating glassmorphic bottom navigation shell
│   │   ├── home_screen.dart           # Companion dashboard with "Next Event" hero card
│   │   ├── explore_screen.dart        # Event discovery, category chips, live search
│   │   ├── event_details_screen.dart  # Hero image, quantity picker, real-time total, book CTA
│   │   ├── booking_success_screen.dart# Confirmation badge, reference, 1-tap "View Pass"
│   │   ├── my_bookings_screen.dart    # Ticket vault (Upcoming / Past / Cancelled tabs)
│   │   ├── digital_ticket_screen.dart # Verifiable Digital Ticket Pass with QR code
│   │   └── settings_screen.dart       # Theme selector, user switcher, backend config
│   │
│   ├── widgets/                       # Reusable UI components
│   │   ├── glass_container.dart       # BackdropFilter glassmorphism widget
│   │   ├── event_card.dart            # Event card with status badges & price
│   │   ├── quantity_selector.dart     # Bounded [-] [qty] [+] ticket picker
│   │   ├── booking_card.dart          # Ticket card with status chip & actions
│   │   ├── user_selector.dart         # Bottom sheet mock user switcher
│   │   └── state_views.dart           # Loading, Error, and Empty state widgets
│   │
│   ├── theme/
│   │   └── app_theme.dart             # Material 3 light/dark tokens & Google Fonts
│   │
│   └── utils/
│       ├── constants.dart             # Categories, icons, colors, INR currency formatter
│       └── api_constants.dart         # Backend URL, build-time mode and endpoint routes
│
├── pubspec.yaml                       # Dependencies (provider, qr_flutter, http, etc.)
└── test/
    └── widget_test.dart               # Automated smoke & model integration tests
```

---

## 6. State Management

All state management is implemented using **Provider + ChangeNotifier**:

1. **`ThemeProvider`**: Manages `AppThemeMode` (System, Light, Dark) and persists preference to `SharedPreferences`.
2. **`UserProvider`**: Tracks active mock user, loads users from `ApiService.getUsers()`, and persists selected user ID to `SharedPreferences`.
3. **`EventProvider`**: Manages event catalog, active category filter, live multi-field search (`name`, `description`, `venue`), and provides `syncEventSeats()` for real-time local seat updates.
4. **`BookingProvider`**: Dispatches `createBooking()` and `cancelBooking()`, tracks user ticket history, and synchronizes updated capacity back to `EventProvider`.

---

## 7. API Layer

The app uses an interface-based architecture:
```dart
abstract class ApiService {
  factory ApiService() {
    return ApiConstants.useMockApi ? MockApiService() : RealApiService();
  }
  Future<List<User>> getUsers();
  Future<User> getUserById(String id);
  Future<List<Event>> getEvents();
  Future<Event> getEventById(String id);
  Future<Booking> createBooking({...});
  Future<List<Booking>> getUserBookings(String userId);
  Future<Booking> cancelBooking(String bookingId);
}
```

---

## 8. Real Backend Integration (Actual Express Endpoints)

| Method | Actual Endpoint | Request Body | Response Structure | Mobile File |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/users` | None | `{ success: true, users: [...] }` | `UserProvider` |
| `GET` | `/api/users/:id` | None | `{ success: true, user: {...} }` | `UserProvider` |
| `GET` | `/api/events` | Query: `?category=...&search=...` | `{ success: true, count: N, events: [...] }` | `EventProvider` |
| `GET` | `/api/events/:id` | None | `{ success: true, event: {...} }` | `EventDetailsScreen` |
| `POST` | `/api/bookings` | `{ "userId": "...", "eventId": "...", "quantity": 2 }` | `{ success: true, message: "...", booking: {...}, event: { remainingSeats } }` | `BookingProvider` |
| `GET` | `/api/bookings/user/:userId`| None | `{ success: true, bookings: [...] }` (with populated event) | `BookingProvider` |
| `PATCH`| `/api/bookings/:id/cancel` | None | `{ success: true, message: "...", booking: {...} }` | `BookingProvider` |

---

## 9. Data Flow (Real Mode)

```
MongoDB ──> Express API ──> JSON Response ──> RealApiService ──> Model.fromJson ──> Provider ──> UI Widget
```

---

## 10. Mock Data Flow (Mock Mode)

```
MockApiService (Seed Data) ──> In-Memory State ──> Provider ──> Model ──> UI Widget
```

---

## 11. Booking Flow

1. User selects ticket quantity in `EventDetailsScreen` (`1 <= quantity <= availableSeats`).
2. User taps **BOOK TICKETS**; `BookingProvider.createBooking()` is called.
3. In Real Mode: sends POST to `/api/bookings` with `{ userId, eventId, quantity }`. In Mock Mode: `MockApiService` validates seat quotas and decrements available count.
4. Available seats in `EventProvider` are updated via `syncEventSeats()`.
5. User is redirected to `BookingSuccessScreen` with a direct CTA: **"View Digital Ticket Pass"**.

---

## 12. Cancellation Flow

1. In `MyBookingsScreen`, user taps the cancel icon on a confirmed booking.
2. Confirmation dialog informs the user that seats will be returned to the event capacity.
3. User confirms; `BookingProvider.cancelBooking(bookingId)` executes.
4. In Real Mode: PATCH `/api/bookings/:id/cancel` triggers atomic seat increment in MongoDB. In Mock Mode: `MockApiService` increments `availableSeats` in memory.
5. Status changes to `CANCELLED` and event capacity reflects restored seats.

---

## 13. Digital Ticket Pass & QR Code

- **Screen**: `DigitalTicketScreen`
- **Visual Design**: Boarding pass design with category gradient header, attendee metadata, perforated dotted tear line with circular notch cutouts.
- **QR Code**: Rendered via `qr_flutter` using a deterministic payload:
  `SNAPTICKET|<BOOKING_REFERENCE>|<EVENT_ID>|<USER_ID>`
- **Offline Reliability**: Even if internet connection is lost, confirmed bookings retain their digital pass in memory for gate check-in.

---

## 14. Theme System

- **Modes**: `System Default`, `Light`, `Dark`.
- **Persistence**: Saved under key `selected_theme_mode` in `SharedPreferences`.
- **Colors**: Centralized in `AppTheme` (Deep Indigo `#6366F1`, Emerald `#10B981`, Slate surfaces `#0B0F19` / `#F8FAFC`).

---

## 15. Glassmorphism Design System

- Encapsulated in `GlassContainer`.
- Uses `BackdropFilter` with `ImageFilter.blur(sigmaX: 12, sigmaY: 12)` and subtle 1px border highlights.
- Optimized to prevent frame drops by restricting blur to key container cards.

---

## 16. Local Persistence (SharedPreferences)

1. `selected_theme_mode`: Persists `system`, `light`, or `dark`.
2. `selected_user_id`: Persists the active mock user across app restarts.

---

## 17. Networking & Emulator Setup

- **Android Emulator**: Uses `http://10.0.2.2:5000/api` to communicate with the Node.js server running on host `localhost:5000`.
- **iOS Simulator**: Uses `http://localhost:5000/api`.
- **Physical Phone**: Uses local Wi-Fi LAN IP (e.g., `http://192.168.1.150:5000/api`).

---

## 18. Error Handling

- Real HTTP error codes (400 Bad Request, 404 Not Found, 500 Internal Error) are parsed and displayed cleanly via `SnackBar` or `ErrorStateView` with retry buttons.
- Stale concurrency: If another user books the last seats before submission, backend returns `400 Insufficient seats available`, which Flutter displays with a prompt to refresh.

---

## 19. Automated Testing

Run tests with:
```bash
flutter test
```
Tests verify:
- Mock service data fetching
- Seat decrement upon booking
- Exceeded quota error handling
- Booking reference generation (`BK-2026-XXXXXX`)
- Cancellation seat restoration
- Real backend JSON deserialization for User, Event, and populated Booking schemas.

---

## 20. Troubleshooting

1. **Connection Refused on Android**: Verify using `10.0.2.2:5000` instead of `localhost:5000`.
2. **Missing Image URLs**: `EventCard` uses `errorBuilder` gradient fallbacks.
3. **RenderFlex Overflows**: Eliminated via `SingleChildScrollView`, `Expanded`, `Flexible`, and `SafeArea`.

---

## 21. 40+ Project-Specific Interview Questions & Answers

### Product Strategy & System Design
1. **Q: Why does this app need to exist if the website already works?**  
   *A:* The website is designed for wide event discovery and search on large screens. The mobile app serves as the personal ticket companion: providing 1-tap access to "Your Next Event", verifiable digital QR ticket passes for gate check-in, and offline ticket viewing.
2. **Q: How does the mobile app differ from the React website?**  
   *A:* The mobile app includes a "Next Event" hero card on Home, a boarding pass Digital Ticket with QR code, tabbed ticket management (`Upcoming`, `Past`, `Cancelled`), and persistent theme/user preferences.
3. **Q: Does Flutter talk directly to MongoDB?**  
   *A:* No. Direct database connections from mobile clients expose database credentials and bypass server validation. Flutter communicates with the Express.js REST API over HTTP.
4. **Q: How do you switch between Mock Mode and Real Backend?**  
   *A:* The real API is the default. Pass `--dart-define=API_BASE_URL=https://YOUR-RENDER-SERVICE.onrender.com/api` for a production build. Mock mode is opt-in with `--dart-define=USE_MOCK_API=true`.
5. **Q: Who is authoritative for seat availability?**  
   *A:* The backend MongoDB database. The mobile UI is optimistic, but the server atomically verifies `availableSeats >= quantity` using `findOneAndUpdate({ availableSeats: { $gte: qty } })`.
6. **Q: What happens if two users try to book the last seat simultaneously?**  
   *A:* The MongoDB atomic decrement query succeeds for only one request. The second request returns a `400 Insufficient seats available`, which the mobile app displays gracefully.

### State Management & Architecture
7. **Q: Why Provider over BLoC for this hackathon?**  
   *A:* Provider is lightweight, easy to maintain, official, and eliminates unnecessary boilerplate while giving reactive updates via `ChangeNotifier`.
8. **Q: How does `ChangeNotifier` work?**  
   *A:* It implements the Observer pattern. When state changes, calling `notifyListeners()` tells listening widgets to rebuild.
9. **Q: What are the 4 Providers in this project?**  
   *A:* `ThemeProvider`, `UserProvider`, `EventProvider`, and `BookingProvider`.
10. **Q: How are available seats updated locally after a booking?**  
    *A:* `BookingProvider` calls `EventProvider.syncEventSeats(eventId, newSeatCount)`, immediately updating the Home and Details screens without a network refetch.
11. **Q: What is the purpose of the `ApiService` abstraction?**  
    *A:* It decouples UI from the data source, allowing complete offline testing in `MockApiService` and instant transition to `RealApiService` without rewriting UI code.
12. **Q: What is the format of the QR code payload?**  
    *A:* `SNAPTICKET|<BOOKING_REFERENCE>|<EVENT_ID>|<USER_ID>`.

### Dart & Networking
13. **Q: What is `Future` in Dart?**  
    *A:* A representation of an asynchronous computation that will produce a value or error in the future.
14. **Q: What is the role of `async` and `await`?**  
    *A:* Syntactic sugar over `Future.then()`, allowing asynchronous code to be written linearly and readably.
15. **Q: Why does the Android emulator use `10.0.2.2`?**  
    *A:* Inside Android emulators, `127.0.0.1` refers to the virtual device itself. `10.0.2.2` is the special routing alias to the host machine's loopback interface.
16. **Q: How does `RealApiService` handle network timeouts?**  
    *A:* It uses `.timeout(ApiConstants.connectTimeout)` (10s) and `.timeout(ApiConstants.receiveTimeout)` (15s) with user-friendly error handling.
17. **Q: How does JSON serialization work in Dart?**  
    *A:* Through factory constructors `Model.fromJson(Map<String, dynamic> json)` and `Map<String, dynamic> toJson()`.
18. **Q: What HTTP verbs are used in this project?**  
    *A:* `GET` (fetching events/users/bookings), `POST` (creating bookings), and `PATCH` (cancelling bookings).

### UI & Performance
19. **Q: What is `BackdropFilter`?**  
    *A:* A Flutter widget that applies an `ImageFilter` (like Gaussian blur) to whatever is painted underneath its child area.
20. **Q: Why can excessive blur harm performance?**  
    *A:* Gaussian blur requires multi-pass fragment shader rendering over pixel buffers. Overusing it on high-resolution screens can reduce frame rates below 60fps.
21. **Q: How did you prevent `RenderFlex` overflow errors?**  
    *A:* By using `SingleChildScrollView`, `ListView.builder`, `Flexible`, `Expanded`, and `SafeArea` across all screens.
22. **Q: How does theme switching work?**  
    *A:* `ThemeProvider` toggles `ThemeMode` in `MaterialApp` and writes the mode string to `SharedPreferences`.

### Backend & Collaboration
23. **Q: How did you inspect the backend before modifying Flutter?**  
    *A:* By reviewing `server.js`, `bookingRoutes.js`, `bookingController.js`, and Mongoose schemas in the team repository to align JSON request/response formats.
24. **Q: What is the backend booking reference format?**  
    *A:* `BK-YYYY-XXXXXX` (e.g., `BK-2026-849201`).
25. **Q: What fields does the real backend expect for `POST /api/bookings`?**  
    *A:* `{ "userId": "...", "eventId": "...", "quantity": 2 }`.
26. **Q: How does cancellation restore seats in the backend?**  
    *A:* In `cancelBooking`, the backend marks status as `CANCELLED`, finds the event, and updates `availableSeats = Math.min(totalSeats, availableSeats + quantity)`.
27. **Q: Why use `SharedPreferences` instead of SQLite for settings?**  
    *A:* `SharedPreferences` provides lightweight key-value storage ideal for theme and user ID persistence without SQLite database overhead.
28. **Q: How would you add real user authentication later?**  
    *A:* Replace `UserProvider` mock switching with JWT login, storing tokens in `flutter_secure_storage` and attaching `Authorization: Bearer <token>` in `RealApiService`.
29. **Q: How would you implement push notifications?**  
    *A:* Integrate Firebase Cloud Messaging (FCM) using `firebase_messaging` and register device push tokens with the Express server.
30. **Q: What happens if an image fails to load?**  
    *A:* The `Image.network` widget uses an `errorBuilder` that renders a stylized gradient container with category icons.
31. **Q: What categories does SnapTicket support?**  
    *A:* `Technology`, `Music`, `Sports`, `Entertainment`, `Business`, and `Workshop`.
32. **Q: How is currency formatted?**  
    *A:* Via `NumberFormat.currency(locale: 'en_IN', symbol: '₹')`.
33. **Q: What is `IndexedStack` used for in `MainNavigationScreen`?**  
    *A:* It preserves the scroll position and state of all 4 tabs (`Home`, `Explore`, `My Tickets`, `Settings`) when switching between them.
34. **Q: How do you debug an HTTP 500 error?**  
    *A:* Inspect server console logs, verify payload structure matches controller expectations, and check MongoDB connection status.
35. **Q: How do you debug an HTTP 404 error?**  
    *A:* Verify the endpoint URL path in `api_constants.dart` matches the Express route definitions in `routes/`.
36. **Q: Why shouldn't API secrets be stored in Flutter code?**  
    *A:* Client-side binaries (APKs/IPAs) can be reverse-engineered and decompiled, exposing hardcoded secrets.
37. **Q: How does the digital ticket handle cancelled tickets?**  
    *A:* It overlays a `VOID / CANCELLED` warning in place of the QR code to prevent fraudulent gate check-in.
38. **Q: What is the purpose of `List.unmodifiable` in `MockApiService`?**  
    *A:* It prevents external providers or widgets from mutating the internal data store directly, enforcing unidirectional data flow.
39. **Q: How would you scale the mobile app for thousands of concurrent users?**  
    *A:* Implement pagination (`limit` & `skip` query params) on `/api/events`, cache static event images via `cached_network_image`, and utilize CDN caching for event metadata.
40. **Q: What was your personal contribution to SnapTicket?**  
    *A:* See Section 22 below.

---

## 22. My Contribution Statement (For Interview Panel)

> *"I engineered the Flutter mobile frontend for SnapTicket. Recognizing that our web teammate was already building a broad event exploration portal, I designed the mobile app with a clear, distinct purpose: a personal 'Ticket Companion' optimized for fast access to upcoming bookings and digital gate admission. I built an interface-based service architecture that allowed complete frontend development with a realistic mock engine before seamlessly aligning with our team's Express.js + MongoDB backend. The app features Material 3 glassmorphism, responsive bottom navigation, real-time seat synchronization, and verifiable QR digital passes."*

---

## 23. 2–3 Minute Live Demo Script

1. **Launch & Theme (0:00 - 0:30)**:
   - *"Welcome to SnapTicket Mobile. Notice the glassmorphic Material 3 UI. We have instant Dark/Light theme switching persisted via SharedPreferences."*
2. **Personalized Home & Next Event Hero (0:30 - 1:00)**:
   - *"On Home, the user is greeted personally with an active 'Your Next Event' hero card showing their upcoming booking."*
   - *"Tapping 'VIEW DIGITAL TICKET PASS' immediately opens their digital boarding pass with a verifiable QR code for gate admission."*
3. **Explore & Booking Flow (1:00 - 1:45)**:
   - *"In Explore, we can search by title, venue, or category. Opening an event displays live seat availability."*
   - *"Adjusting ticket quantity calculates total price in INR. Tapping 'BOOK TICKETS' reserves the seats, updates live availability, and issues a new digital pass."*
4. **My Tickets & Cancellation (1:45 - 2:30)**:
   - *"In 'My Tickets', passes are organized into Upcoming, Past, and Cancelled tabs."*
   - *"Cancelling a ticket restores the seats to the event capacity in real-time."*
   - *"Finally, building with the Render API URL connects this exact UI directly to our live Express + MongoDB backend with zero UI code changes."*
