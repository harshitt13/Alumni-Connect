# Alumni Connect

An Alumni networking mobile application built with **Flutter** and **Firebase**. Designed for university alumni to stay connected, discover peers, and attend events with a dedicated Admin Dashboard for management.

Android-only native application optimized for mobile user experience.

---

## Table of Contents

1. [Overview](#overview)
2. [Platform and Technology](#platform-and-technology)
3. [Features](#features)
   - [User Features](#user-features)
   - [Admin Features](#admin-features)
4. [Architecture](#architecture)
5. [Project Structure](#project-structure)
6. [Data Models](#data-models)
7. [Navigation Flow](#navigation-flow)
8. [Firestore Database Schema](#firestore-database-schema)
9. [Tech Stack](#tech-stack)
10. [Getting Started](#getting-started)
11. [Build and Deployment](#build-and-deployment)
12. [License](#license)
13. [Support](#support)

---

## Overview

Alumni Connect is a mobile platform for university alumni networking. The application enables alumni to:

- Maintain connections with fellow graduates
- Discover professional opportunities and peer networks
- Attend curated alumni events
- Send direct messages with one-on-one messaging
- Receive real-time notifications about important updates
- Manage their professional profile

The Admin Dashboard provides university administrators the ability to manage alumni records, curate events, and monitor system activity.

---

## Platform and Technology

**Current Build Target**: Android Only

The project was originally a cross-platform Flutter application supporting iOS, Web, Windows, Linux, and macOS. It has been refactored to focus exclusively on Android development to streamline the development workflow and focus resources on the primary mobile platform.

**Android Configuration**:
- Minimum SDK: API 21 (Android 5.0)
- Target SDK: Latest stable Android version
- Package: com.alumni.alumni_connect
- Build System: Gradle (Kotlin)

---

## Features

### User Features

| Feature | Description |
|---|---|
| Splash Screen | Animated branded launch screen with logo fade-in and smooth transition |
| Onboarding Carousel | 3-slide first-launch introduction with skip option |
| Authentication | Secure Firebase Email/Password authentication with validation |
| Auto Profile Creation | Registration automatically creates a Firestore alumni profile |
| Home Dashboard | Personalized greeting, quick actions, upcoming events with loading states |
| Unread Notifications Badge | Real-time counter for system notifications |
| Unread Messages Badge | Real-time counter for chat messages |
| Notification Panel | Draggable bottom sheet displaying recent notifications |
| Alumni Directory | Search and filter alumni by name, company, and major with refresh |
| Alumni Profile Detail | Detailed view with profile information and messaging capability |
| Messaging System | One-on-one chat with real-time unread count tracking |
| Events Feed | Visual event cards with RSVP functionality |
| Profile Management | Dynamically loaded user profile from Firestore |
| Dark Mode | Full theme toggle with persistent storage |
| Session Management | Secure logout with Firebase session clearing |

### Admin Features

| Feature | Description |
|---|---|
| Admin Dashboard | System overview with live alumni and event counts |
| Notification Badge | Real-time notifications for admin updates |
| Alumni Management | Add new alumni records with Firestore synchronization |
| Alumni Deletion | Remove alumni records with confirmation |
| Event Management | Add new events to the system |
| Event Deletion | Remove events with confirmation |
| Role-Based Routing | Automatic routing to admin panel for admin@admin.com |
| Activity Monitoring | View recent system activities and changes |

---

## Architecture

The application follows a layered architecture pattern:

```
Presentation Layer (Screens / UI)
        |
State Management Layer (AppProvider)
        |
Business Logic Layer (Authentication, Data Operations)
        |
Data Access Layer (Firebase / Mock Data)
```

Core Components:

- Presentation Layer: All screen widgets and UI components under lib/screens/
- State Management: AppProvider using Provider package with ChangeNotifier pattern
- Navigation: GoRouter for declarative routing between screens
- Data Layer: Firebase Auth for authentication and Cloud Firestore for data persistence
- Fallback: Mock data available for development and testing without Firebase

Authentication Architecture:

- Role-based routing: admin@admin.com routes to AdminNavigation, other users to MainNavigation
- JWT tokens handled by Firebase Auth automatically
- Session persistence via Firebase SDK

---

## Project Structure

```
lib/
├── main.dart                           # Application entry point
│                                       # Firebase initialization
│                                       # Provider setup
│                                       # Onboarding state management
│
├── firebase_options.dart               # Auto-generated Firebase configuration
│                                       # Platform-specific credentials
│
├── data/
│   ├── app_provider.dart               # Central state management
│   │                                   # Authentication logic
│   │                                   # Firestore operations (CRUD)
│   │                                   # Theme management
│   │
│   └── mock_data.dart                  # Fallback data for development
│
├── models/
│   ├── alumni_model.dart               # Alumni data structure
│   ├── event_model.dart                # Event data structure
│   ├── message_model.dart              # Message data structure
│   └── notification_model.dart         # Notification data structure
│
├── router/
│   └── app_router.dart                 # GoRouter configuration
│
├── screens/
│   ├── splash_screen.dart              # Initial loading screen
│   ├── onboarding_screen.dart          # First-time user introduction
│   ├── login_screen.dart               # User authentication interface
│   ├── registration_screen.dart        # New user registration interface
│   ├── main_navigation_bar.dart        # User app navigation
│   ├── home_dashboard.dart             # User home screen
│   ├── notification_panel.dart         # Notification display
│   ├── chat_screen.dart                # Messaging interface
│   ├── alumni_directory.dart           # Alumni listing and search
│   ├── alumni_profile_detail.dart      # Individual alumni profile
│   ├── events_screen.dart              # Events listing
│   ├── profile_screen.dart             # User profile management
│   │
│   └── admin/
│       ├── admin_navigation_bar.dart   # Admin app navigation
│       ├── admin_dashboard.dart        # Admin overview
│       ├── manage_alumni_screen.dart   # Alumni management interface
│       └── manage_events_screen.dart   # Events management interface
│
├── theme/
│   └── app_theme.dart                  # Light and dark theme definitions
│
└── widgets/
    └── custom_text_field.dart          # Reusable text input component

android/
├── app/
│   ├── build.gradle.kts                # App-level build configuration
│   ├── google-services.json            # Firebase configuration
│   └── src/
│       └── main/
│           └── AndroidManifest.xml     # Android manifest
│
├── gradle/                              # Gradle wrapper
├── build.gradle.kts                    # Project-level build configuration
└── settings.gradle.kts                 # Gradle settings
```

---

## Data Models

### Alumni Model
```dart
class AlumniModel {
  String name;
  String email;
  String profileImageUrl;
  String major;
  int graduationYear;
  String company;
  String role;
  double cgpa;
}
```

### Event Model
```dart
class EventModel {
  String title;
  String description;
  DateTime date;
  String location;
  String imageUrl;
}
```

### Message Model
```dart
class MessageModel {
  String sender;
  String senderName;
  String text;
  DateTime timestamp;
  bool isRead;
}
```

### Notification Model
```dart
class NotificationModel {
  String userId;
  String title;
  String message;
  String type;  // 'message', 'event', 'alert', 'system'
  DateTime timestamp;
  bool isRead;
  String? relatedId;
  Map<String, dynamic>? data;
}
```

---

## Navigation Flow

**User Flow (Non-Admin)**:
1. App Start -> Splash Screen (3 seconds)
2. Check SharedPreferences for onboarding flag
3. If first launch -> Onboarding Carousel -> Mark complete in SharedPreferences
4. Login Screen (or Registration Screen)
5. Role Check: If email == admin@admin.com -> Admin flow, else -> User flow
6. MainNavigation with 4 tabs:
   - Home Dashboard
   - Alumni Directory
   - Events Screen
   - Profile Screen

**Admin Flow**:
1. Same as user until role check
2. Role Check: Email == admin@admin.com
3. AdminNavigation with admin-specific screens:
   - Admin Dashboard
   - Manage Alumni
   - Manage Events
   - Admin Profile

**Messaging Flow**:
- From any Alumni Profile Detail -> Click "Message" button -> ChatScreen
- ChatScreen displays one-on-one conversation
- Messages stream in real-time from Firestore

**Notification Flow**:
- Notifications can be triggered by:
  - New messages from other users
  - Event updates
  - System announcements by admin
- Users see badge on home icon
- Tap badge -> NotificationPanel (draggable bottom sheet)
- Tap notification -> Navigate based on type (message -> chat, event -> event details)

---

## Firestore Database Schema

**Database Structure**:
```
alumni-portal-54d75/ (Firebase Project)
├── alumni/
│   ├── user1@example.com
│   ├── user2@example.com
│   └── admin@admin.com
│
├── events/
│   ├── event-001
│   ├── event-002
│   └── event-003
│
├── chats/
│   ├── chat-001
│   │   └── messages/
│   │       ├── msg-001
│   │       └── msg-002
│   └── chat-002
│       └── messages/
│           └── msg-003
│
└── notifications/
    ├── notif-001
    ├── notif-002
    └── notif-003
```

### Alumni Collection

The `alumni` collection stores all user profiles.

| Field | Type | Description |
|---|---|---|
| name | string | Full name of the alumnus |
| email | string | Unique email address |
| profileImageUrl | string | Avatar image URL |
| major | string | Field of study |
| graduationYear | integer | Year of graduation |
| company | string | Current employer |
| role | string | Current job title |
| cgpa | number | GPA achievement |

**Document ID**: Uses email as document ID for quick lookups

### Events Collection

The `events` collection stores all events.

| Field | Type | Description |
|---|---|---|
| title | string | Event name |
| description | string | Event details |
| date | timestamp | Event date and time |
| location | string | Event location |
| imageUrl | string | Event poster/image |

### Chats Collection

The `chats` collection stores chat conversations.

| Field | Type | Description |
|---|---|---|
| participants | array | Email addresses of participants |
| lastMessage | string | Last message content |
| lastTimestamp | timestamp | Time of last message |
| unreadCount | map | Per-user unread message count |

**Document ID**: Auto-generated by Firestore

### Messages Sub-collection

Messages are stored in `chats/{chatId}/messages` sub-collection.

| Field | Type | Description |
|---|---|---|
| sender | string | Email of message sender |
| senderName | string | Display name of sender |
| text | string | Message content |
| timestamp | timestamp | When message was sent |
| isRead | boolean | Whether recipient has read it |

### Notifications Collection

The `notifications` collection stores system and message notifications.

| Field | Type | Description |
|---|---|---|
| userId | string | Recipient user email |
| title | string | Notification title |
| message | string | Notification content |
| type | string | Category (message/event/alert/system) |
| timestamp | timestamp | When notification was created |
| isRead | boolean | Whether user has read it |
| relatedId | string | ID of related document |
| data | map | Additional context data |

**Document ID**: Auto-generated by Firestore

---

## Tech Stack

| Technology | Purpose | Version |
|---|---|---|
| Flutter | Mobile framework | 3.11.0+ |
| Dart | Programming language | 3.11.0+ |
| Firebase Core | Firebase initialization | 4.5.0 |
| Firebase Auth | User authentication | 6.2.0 |
| Cloud Firestore | Cloud database | 6.1.3 |
| Provider | State management | 6.1.5+1 |
| GoRouter | Navigation routing | 17.1.0 |
| Google Fonts | Typography | 8.0.2 |
| Lucide Icons | Icon library | 0.257.0 |
| Shimmer | Loading animations | 3.0.0 |
| Flutter Staggered Animations | List animations | 1.1.1 |
| Shared Preferences | Local storage | 2.5.4 |
| Gradle | Build tool | 8.0+ |
| Java/Kotlin | Android native | 11+ / 1.8+ |

---

## Getting Started

### Prerequisites

Ensure you have the following installed:

- Flutter SDK 3.11.0 or higher
- Dart 3.11.0 or higher
- Android SDK (API 21 minimum, target API 34+)
- Java Development Kit (JDK 11+)
- Git
- Firebase CLI (optional, for advanced Firebase management)
- A Firebase project with Authentication and Firestore enabled

### Installation

Clone and setup the project:

```bash
# Clone the repository
git clone <repository-url>
cd "Alumni Portal"

# Install Flutter dependencies
flutter pub get

# Configure Firebase for Android
# If not already configured, run:
dart pub global activate flutterfire_cli
flutterfire configure --project=alumni-portal-54d75

# Verify Android setup
flutter doctor -v
```

### Firebase Configuration

The Firebase configuration is already set up for Android via FlutterFire CLI. The configuration file `lib/firebase_options.dart` is auto-generated and contains:

- Web Firebase configuration (kept for reference)
- Android Firebase configuration
- iOS Firebase configuration (for future multi-platform support)

Key Firebase files for Android:

- `android/app/google-services.json` - Android Firebase config (ignored by .gitignore)
- `lib/firebase_options.dart` - Dart Firebase initialization

Important: Never commit `google-services.json` to the repository. It contains sensitive credentials.

### Running the Application

Run the app on an Android emulator or physical device:

```bash
# List available devices
flutter devices

# Run on default device
flutter run

# Run with verbose output for debugging
flutter run -v

# Run on specific device
flutter run -d <device-id>

# Run in release mode (optimized)
flutter run --release
```

### Setting Up Firebase Users

1. Go to [Firebase Console](https://console.firebase.google.com/project/alumni-portal-54d75)
2. Navigate to Authentication section
3. Create test users:
   - Admin: `admin@admin.com` / `password123`
   - User: `john@example.com` / `password123`
4. Go to Firestore Database and add alumni records for each user

Creating an alumni document manually:

1. In Firebase Console, go to Firestore Database
2. Create collection `alumni`

### Admin Access

To access the Admin Dashboard:

1. Register or login with `admin@admin.com`
2. The app automatically detects the admin role and routes to AdminNavigation
3. From the admin dashboard, you can:
   - Add new alumni
   - Delete alumni
   - Add new events
   - Delete events
   - View system statistics

---

## Build and Deployment

### Building for Android

Build an APK (unsigned debug build):

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

Build an APK (release optimized):

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Build an Android App Bundle (AAB) for Play Store:

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Signing for Play Store

Create a keystore (do this once):

```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Configure signing in `android/app/build.gradle.kts`:

```kotlin
signingConfigs {
    release {
        keyAlias = "upload"
        keyPassword = "your-key-password"
        storeFile = file("/path/to/key.jks")
        storePassword = "your-store-password"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.release
    }
}
```

Build the signed release bundle:

```bash
flutter build appbundle --release
```

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

## Support

For issues, questions, or feedback:

- Open a GitHub issue with detailed description
- Include device info (Android version, device model)
- Attach screenshots or error logs
- For confidential issues, contact the project maintainer directly

**Project Repository**: [harshitt13/Alumni-Connect](https://github.com/harshitt13/Alumni-Connect)
