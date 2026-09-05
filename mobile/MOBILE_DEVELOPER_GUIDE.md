# 🎟️ SnapTicket — Smart Event Ticket Booking App

> **A Flutter-based mobile ticket companion for discovering events, booking tickets, managing reservations, and accessing verifiable digital QR ticket passes.**

SnapTicket is a full-stack event ticket reservation platform consisting of a **React web application**, an **Express.js + MongoDB backend**, and a dedicated **Flutter mobile application**.

The Flutter mobile app is designed as a **personal ticket wallet and day-of-event companion**, providing quick access to upcoming events, digital tickets, booking history, and QR-based admission passes.

---

## ✨ Features

### 📱 Mobile Application

* 🏠 Personalized home dashboard
* 🎫 Upcoming event / "Your Next Event" card
* 🔎 Event discovery and search
* 🏷️ Category-based event filtering
* 📅 Event details and availability
* 🎟️ Ticket quantity selection
* 💰 Real-time ticket price calculation
* ✅ Instant booking confirmation
* 📋 Upcoming, past, and cancelled bookings
* ❌ Ticket cancellation
* 📱 Digital ticket pass
* 🔳 QR code generation for ticket verification
* 🌐 Real backend and mock API support
* 🌙 Light, dark, and system themes
* 💾 Local preference persistence
* 🎨 Material 3 glassmorphism UI
* ⚡ Reactive state management using Provider

---

## 🎯 Project Purpose

SnapTicket aims to simplify the complete event ticketing experience.

Instead of using the mobile application as a smaller version of the website, the Flutter application focuses on the user's **personal ticket management and event attendance experience**.

### Web Application

The React web application focuses primarily on:

* Event discovery
* Event exploration
* Searching and comparing events
* Detailed event information
* Broad browsing experience

### Flutter Mobile Application

The mobile application focuses primarily on:

* Personal ticket management
* Upcoming event access
* Digital ticket passes
* QR-based admission
* Booking history
* Quick access while attending an event

This makes the mobile application a **personal Ticket Wallet & Day-of-Event Companion** rather than a simple mobile version of the website.

---

## 🏗️ System Architecture

```text
                         ┌─────────────────────────┐
                         │     MongoDB Database     │
                         └────────────┬────────────┘
                                      │
                                      ▼
                         ┌─────────────────────────┐
                         │   Express.js Backend    │
                         │       REST API           │
                         └────────────┬────────────┘
                                      │
                         ┌────────────┴────────────┐
                         │                         │
                         ▼                         ▼
                ┌─────────────────┐      ┌─────────────────┐
                │   React Web App │      │ Flutter Mobile  │
                │ Event Discovery │      │ Ticket Companion│
                │    & Booking    │      │   & Digital Pass│
                └─────────────────┘      └────────┬────────┘
                                                  │
                                                  ▼
                                      ┌─────────────────────┐
                                      │     ApiService      │
                                      └──────────┬──────────┘
                                                 │
                                      ┌──────────┴──────────┐
                                      │                     │
                                      ▼                     ▼
                              ┌──────────────┐      ┌──────────────┐
                              │ RealApiService│      │MockApiService│
                              │   HTTP/REST   │      │  Local Data  │
                              └──────────────┘      └──────────────┘
```

---

## 🛠️ Tech Stack

### Frontend — Flutter

* Flutter
* Dart
* Material 3
* Provider
* ChangeNotifier
* SharedPreferences
* QR Flutter
* Google Fonts

### Backend

* Node.js
* Express.js
* MongoDB
* Mongoose
* REST API

### Web Application

* React

### Development Tools

* Git
* GitHub
* Android Studio
* VS Code
* Flutter SDK
* Android Emulator

---

## 📂 Project Structure

```text
mobile/
│
├── lib/
│   │
│   ├── main.dart
│   │
│   ├── models/
│   │   ├── user.dart
│   │   ├── event.dart
│   │   └── booking.dart
│   │
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── mock_api_service.dart
│   │   └── real_api_service.dart
│   │
│   ├── providers/
│   │   ├── theme_provider.dart
│   │   ├── user_provider.dart
│   │   ├── event_provider.dart
│   │   └── booking_provider.dart
│   │
│   ├── screens/
│   │   ├── main_navigation_screen.dart
│   │   ├── home_screen.dart
│   │   ├── explore_screen.dart
│   │   ├── event_details_screen.dart
│   │   ├── booking_success_screen.dart
│   │   ├── my_bookings_screen.dart
│   │   ├── digital_ticket_screen.dart
│   │   └── settings_screen.dart
│   │
│   ├── widgets/
│   │   ├── glass_container.dart
│   │   ├── event_card.dart
│   │   ├── quantity_selector.dart
│   │   ├── booking_card.dart
│   │   ├── user_selector.dart
│   │   └── state_views.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart
│   │
│   └── utils/
│       ├── constants.dart
│       └── api_constants.dart
│
├── test/
│   └── widget_test.dart
│
└── pubspec.yaml
```

---

## 🧠 Application Architecture

SnapTicket follows a layered architecture to keep the UI, business logic, and networking separate.

```text
UI / Screens
     │
     ▼
Providers
     │
     ▼
ApiService
     │
 ┌───┴────────────┐
 ▼                ▼
Mock API       Real API
                  │
                  ▼
             Express.js
                  │
                  ▼
               MongoDB
```

---

## 🔄 State Management

The application uses **Provider + ChangeNotifier** for state management.

### ThemeProvider

Responsible for:

* Light / Dark / System theme
* Persisting selected theme
* Updating application theme

### UserProvider

Responsible for:

* Managing the active user
* Loading users
* Persisting selected user

### EventProvider

Responsible for:

* Event catalogue
* Event search
* Category filtering
* Event seat availability
* Synchronizing available seats

### BookingProvider

Responsible for:

* Creating bookings
* Loading booking history
* Cancelling bookings
* Updating event seat availability

---

## 🌐 API Layer

SnapTicket uses an interface-based API architecture.

```dart
abstract class ApiService {
  Future<List<User>> getUsers();
  Future<User> getUserById(String id);
  Future<List<Event>> getEvents();
  Future<Event> getEventById(String id);
  Future<Booking> createBooking({...});
  Future<List<Booking>> getUserBookings(String userId);
  Future<Booking> cancelBooking(String bookingId);
}
```

This allows the application to switch between:

* `MockApiService`
* `RealApiService`

without changing the UI or Provider logic.

---

## 🔌 REST API Endpoints

| Method | Endpoint                     | Purpose             |
| ------ | ---------------------------- | ------------------- |
| GET    | `/api/users`                 | Get users           |
| GET    | `/api/users/:id`             | Get user by ID      |
| GET    | `/api/events`                | Get events          |
| GET    | `/api/events/:id`            | Get event details   |
| POST   | `/api/bookings`              | Create booking      |
| GET    | `/api/bookings/user/:userId` | Get user's bookings |
| PATCH  | `/api/bookings/:id/cancel`   | Cancel booking      |

### Create Booking

```http
POST /api/bookings
```

Request:

```json
{
  "userId": "...",
  "eventId": "...",
  "quantity": 2
}
```

---

## 🎟️ Booking Flow

```text
Select Event
     │
     ▼
View Event Details
     │
     ▼
Select Ticket Quantity
     │
     ▼
Check Available Seats
     │
     ▼
Book Tickets
     │
     ▼
Backend Creates Booking
     │
     ▼
Update Available Seats
     │
     ▼
Booking Confirmation
     │
     ▼
Digital Ticket + QR Code
```

### Booking Process

1. User selects an event.
2. User selects the required ticket quantity.
3. Available seats are validated.
4. Booking request is sent to the backend.
5. Backend creates the booking.
6. Event availability is updated.
7. Booking confirmation is displayed.
8. User can open the digital ticket pass.

---

## ❌ Cancellation Flow

```text
My Tickets
     │
     ▼
Select Booking
     │
     ▼
Cancel Ticket
     │
     ▼
Confirmation Dialog
     │
     ▼
Backend Cancellation
     │
     ▼
Seats Restored
     │
     ▼
Booking → CANCELLED
```

When a booking is cancelled, the corresponding ticket quantity is returned to the event's available seat count.

---

## 🔳 Digital Ticket & QR Code

Each confirmed booking generates a digital ticket pass.

The QR code contains a deterministic payload:

```text
SNAPTICKET|<BOOKING_REFERENCE>|<EVENT_ID>|<USER_ID>
```

The digital ticket includes:

* Event information
* Attendee information
* Booking reference
* QR code
* Ticket status
* Event category
* Ticket details

Cancelled tickets display a **VOID / CANCELLED** state instead of an active QR code.

---

## 🎨 UI & Design System

SnapTicket uses a modern **Material 3 glassmorphism design system**.

### Design Features

* Glassmorphic cards
* Backdrop blur
* Gradient surfaces
* Rounded containers
* Material 3 components
* Dark mode
* Light mode
* Responsive layouts
* Animated / interactive UI elements

The glass effect is implemented using Flutter's:

```dart
BackdropFilter
```

with controlled blur to avoid unnecessary rendering overhead.

---

## 🌙 Theme System

The application supports three theme modes:

* System Default
* Light
* Dark

The selected theme is persisted using `SharedPreferences`.

```text
selected_theme_mode
```

---

## 💾 Local Storage

`SharedPreferences` is used for lightweight application preferences.

Currently stored values include:

```text
selected_theme_mode
selected_user_id
```

This allows preferences to remain available after restarting the application.

---

## 🔀 Mock API & Real Backend

SnapTicket supports two API modes.

### Mock Mode

Useful for:

* UI development
* Testing
* Offline development
* Backend-independent development

```text
MockApiService
      ↓
Seed Data
      ↓
In-Memory State
      ↓
Providers
      ↓
UI
```

### Real API Mode

Used for connecting the Flutter application to the Express.js backend.

```text
Flutter
   ↓
RealApiService
   ↓
REST API
   ↓
Express.js
   ↓
MongoDB
```

The same Providers and UI work with both modes.

---

## ⚙️ Installation & Setup

### Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* Git
* Node.js
* MongoDB

Verify Flutter installation:

```bash
flutter doctor
```

---

## 📥 Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd <YOUR_PROJECT_FOLDER>
```

---

## 📦 Install Flutter Dependencies

```bash
flutter pub get
```

---

## ▶️ Run the Application

Connect an Android device or start an emulator and run:

```bash
flutter run
```

---

## 🌐 Backend Configuration

The Flutter application communicates with the Express.js backend through the configured API base URL.

For Android Emulator development, a local backend can use:

```text
http://10.0.2.2:5000/api
```

For iOS Simulator:

```text
http://localhost:5000/api
```

For a physical device, use the computer's local network IP:

```text
http://192.168.x.x:5000/api
```

For production, configure the deployed backend URL through the application's API configuration.

---

## 🚀 Production API Configuration

The application supports build-time API configuration.

Example:

```bash
flutter run --dart-define=API_BASE_URL=https://YOUR-BACKEND-URL/api
```

For mock mode:

```bash
flutter run --dart-define=USE_MOCK_API=true
```

---

## 🧪 Testing

Run Flutter tests using:

```bash
flutter test
```

The project includes tests covering areas such as:

* Mock API data fetching
* Booking creation
* Seat decrement
* Invalid ticket quantity handling
* Booking reference generation
* Cancellation
* Seat restoration
* JSON model deserialization

---

## 🛡️ Error Handling

The application handles common API and UI errors including:

* `400 Bad Request`
* `404 Not Found`
* `500 Internal Server Error`
* Network failures
* Invalid booking quantities
* Insufficient available seats
* Failed image loading
* UI overflow situations

Errors are presented through appropriate UI states such as:

* SnackBars
* Error views
* Retry actions
* Image fallbacks

---

## ⚡ Concurrency & Seat Management

Seat availability is ultimately controlled by the backend database.

The backend validates that sufficient seats are available before completing a booking.

Conceptually:

```text
availableSeats >= requestedQuantity
```

This prevents multiple users from successfully booking the same final seats.

If insufficient seats remain, the backend returns an error and the Flutter application informs the user.

---

## 📱 Supported Event Categories

SnapTicket currently supports:

* 💻 Technology
* 🎵 Music
* ⚽ Sports
* 🎭 Entertainment
* 💼 Business
* 🛠️ Workshop

---

## 💰 Currency

Ticket prices are formatted using Indian currency:

```text
₹
```

The application uses the `en_IN` locale for currency formatting.

---

## 🐛 Troubleshooting

### Android Emulator Cannot Connect to Backend

Do not use:

```text
localhost
```

for an Android emulator when the backend is running on the host machine.

Use:

```text
10.0.2.2
```

Example:

```text
http://10.0.2.2:5000/api
```

### Images Are Not Loading

The application provides fallback UI for failed event images.

### RenderFlex Overflow

The application uses widgets such as:

```text
SingleChildScrollView
ListView
Expanded
Flexible
SafeArea
```

to handle different screen sizes and prevent layout overflow.

---

## 🔐 Security Considerations

The mobile application does **not** connect directly to MongoDB.

The architecture is:

```text
Flutter App
     ↓
Express REST API
     ↓
MongoDB
```

This prevents database credentials and database access logic from being exposed to the mobile client.

API secrets and sensitive credentials should always remain on the backend and should not be hardcoded into the Flutter application.

---

## 🚀 Future Enhancements

Possible future improvements include:

* 🔐 Real user authentication
* 🔑 JWT-based authentication
* 🔒 Secure token storage
* 🔔 Firebase push notifications
* 📧 Email ticket confirmation
* 💳 Online payment integration
* 📍 Location-based event discovery
* 🗺️ Venue maps
* 🎫 Ticket sharing
* 📊 Organizer analytics dashboard
* 🖼️ CDN-based image delivery
* ⚡ Event pagination
* 🚀 API and image caching
* 📱 Offline-first ticket storage

---

## 👨‍💻 My Contribution

I worked primarily on the **Flutter mobile application** of SnapTicket.

My contribution included:

* Designed and developed the Flutter mobile frontend
* Created the Material 3 glassmorphism UI
* Implemented Provider-based state management
* Developed event discovery and search
* Implemented event details and ticket booking
* Developed booking history and cancellation
* Implemented digital ticket passes
* Integrated QR code generation
* Created Mock API architecture for independent development
* Integrated the Flutter application with the Express.js REST API
* Implemented theme persistence using SharedPreferences
* Added error and loading states
* Implemented real-time local seat synchronization
* Added automated Flutter tests

The mobile application was designed specifically as a **personal ticket companion**, complementing the broader event discovery experience of the web application.

---

## 📸 Screenshots

Add screenshots of the application here.

Recommended screenshots:

```text
Home Screen
Explore Screen
Event Details
Booking Success
My Tickets
Digital Ticket
Settings
Dark Mode
```

Example:

```markdown
## 📸 Screenshots

| Home | Explore | Event Details |
|---|---|---|
| ![Home](screenshots/home.png) | ![Explore](screenshots/explore.png) | ![Event](screenshots/event.png) |

| My Tickets | Digital Ticket | Settings |
|---|---|---|
| ![Tickets](screenshots/tickets.png) | ![Ticket](screenshots/digital_ticket.png) | ![Settings](screenshots/settings.png) |
```

---

## 📚 Key Technical Concepts Used

This project demonstrates practical implementation of:

* Flutter
* Dart
* Material 3
* Provider
* ChangeNotifier
* REST APIs
* HTTP networking
* JSON serialization/deserialization
* Node.js
* Express.js
* MongoDB
* Mongoose
* SharedPreferences
* QR code generation
* Mock API architecture
* Interface-based service architecture
* State management
* Error handling
* Responsive UI
* Theme management
* Git & GitHub

---

## 🤝 Collaboration

The project follows a full-stack development approach where different application layers communicate through REST APIs.

```text
React Web
    │
    ├──────────────┐
    │              │
    ▼              ▼
             Express.js
                  │
                  ▼
               MongoDB
                  ▲
                  │
             Flutter App
```

This separation allows the frontend applications and backend to be developed independently while maintaining a consistent API contract.

---

## 📄 License

This project is developed for educational, demonstration, and portfolio purposes.

---

## ⭐ Acknowledgements

Built using:

* Flutter
* Dart
* Node.js
* Express.js
* MongoDB
* React
* Provider
* Material 3
