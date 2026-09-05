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
