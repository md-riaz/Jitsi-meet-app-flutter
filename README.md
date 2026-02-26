# Alora Meet

A production-grade Flutter wrapper for Jitsi Meet, offering seamless video conferencing with fully dynamic configuration, a modern dashboard, and comprehensive settings for every Jitsi SDK option.

[![Flutter CI](https://github.com/md-riaz/Jitsi-meet-app-flutter/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/md-riaz/Jitsi-meet-app-flutter/actions/workflows/flutter_ci.yml)

## Features

- **Dashboard** — Join, create, or schedule meetings from a single hub
- **Join Meeting** — By room code, full URL, meeting UUID, or QR scan
- **Jitsi Admin v1 API Support** — Join via backend-authorized payload (`/api/v1`) with JWT
- **Create Meeting** — Set subject, password, and share link instantly
- **Meeting History** — Searchable, sortable, with one-tap rejoin
- **Profile** — Display name, email, avatar with activity stats
- **36 Jitsi Feature Flags** — Every flag organized into 8 categories, individually toggleable
- **Audio/Video Controls** — Resolution, mute defaults, noise suppression
- **Advanced Config** — JSON editor for Jitsi config overrides with import/export
- **Persistent Storage** — All settings and history saved via Hive
- **Dark & Light Themes** — Professional UI with Inter font

## Architecture

```
lib/
├── app/                     # App entry, theme, routes
│   ├── app.dart
│   ├── theme.dart
│   └── routes.dart
├── core/
│   ├── models/              # Data models
│   │   ├── meeting.dart
│   │   ├── app_settings.dart
│   │   └── user_profile.dart
│   └── services/            # Business logic
│       ├── storage_service.dart
│       ├── api_client.dart
│       ├── jitsi_admin_api_service.dart
│       ├── jitsi_service.dart
│       └── meeting_service.dart
├── features/
│   ├── dashboard/           # Home screen + widgets
│   ├── meeting/             # Active meeting screen
│   ├── settings/            # 6 settings screens
│   ├── history/             # Meeting history
│   └── profile/             # User profile
└── main.dart
```

## Setup

### Prerequisites

- Flutter SDK ≥ 3.2.0
- Android: minSdk 24
- iOS: Platform 15.1+

### Getting Started

### Backend API (optional but recommended)

For Jitsi Admin integration:

- Set **Server URL** in app settings to your app base path (example: `https://openclaw.mdriaz.com.bd/jitsiadmin`)
- In **Profile** use **Jitsi Admin API Login** (email/password) to fetch and save token automatically
  - endpoint: `POST {SERVER_URL}/api/v1/auth/login`
- Manual token paste still supported in **Profile > Jitsi Admin API Token**
- In Join sheet, provide a meeting UUID to trigger backend join flow (`/api/v1/meetings/{id}/join`)

If no token is present, app attempts guest join path (`/api/v1/meetings/{id}/join-guest`) for public meetings.

Invite-only + admission flow:
- Paste invite token in Join sheet (optional field)
- App resolves/accepts token before guest join
- If `ERR_ADMISSION_REQUIRED`, app polls `/api/v1/meetings/{id}/admission-status` until admitted/rejected


```bash
# Clone the repository
git clone https://github.com/md-riaz/Jitsi-meet-app-flutter.git
cd Jitsi-meet-app-flutter

# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

## Settings & Configuration

### Feature Flags (36 flags in 8 categories)

| Category | Flags |
|----------|-------|
| **Meeting Controls** | Chat, Reactions, Raise Hand, Kick Out, Video Share, Speaker Stats, Meeting Name |
| **Views & Layout** | Tile View, Filmstrip, PiP, Fullscreen |
| **Recording & Streaming** | Recording, Live Streaming |
| **Security** | Security Options, Lobby Mode, Meeting Password, Unsafe Room Warning |
| **Navigation** | Welcome Page, Pre-join Page, Settings, Help, Overflow Menu, Toolbox, Server URL Change |
| **Communication** | Invite, Add People, Close Captions, Notifications |
| **Platform** | Android Screen Sharing, iOS Screen Sharing, Call Integration, Car Mode |
| **Other** | Calendar, Conference Timer, Breakout Rooms, Audio Only |

### Audio/Video Settings

- Start with audio/video muted
- Video resolution (180p–1080p)
- Noise suppression toggle

### Advanced

- JSON config overrides editor
- Import/export configuration
- Diagnostics panel

## CI/CD

GitHub Actions workflow at `.github/workflows/flutter_ci.yml`:

- **Lint & Analyze** — `flutter analyze` + `dart format` check
- **Test** — `flutter test --coverage`
- **Build Android APK** — Release APK artifact
- **Build Android App Bundle** — Release AAB artifact

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/meeting_test.dart
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `jitsi_meet_flutter_sdk` | Jitsi Meet SDK integration |
| `provider` | State management |
| `hive` / `hive_flutter` | Local persistence |
| `google_fonts` | Typography (Inter) |
| `intl` | Date formatting |
| `uuid` | Unique ID generation |
| `share_plus` | Meeting link sharing |
| `mobile_scanner` | QR code scanning |
| `qr_flutter` | QR code generation |
| `url_launcher` | URL handling |

## License

This project is open source. See [LICENSE](LICENSE) for details.