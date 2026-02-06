# Smart Home App

A beautiful Flutter home automation application with Supabase backend integration.

## Features

- Multi-home management
- Room-based device organization
- Control lights, thermostats, locks, cameras, and sensors
- Real-time device state updates
- Modern UI with glassmorphism effects
- Secure authentication

## Setup

1. **Configure Supabase**

Edit `lib/config/supabase_config.dart` with your credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

2. **Install Dependencies**

```bash
flutter pub get
```

3. **Run the App**

```bash
flutter run
```

## Database Schema

The app requires the following Supabase tables:
- `profiles` - User profiles
- `homes` - User homes
- `home_members` - Home access control
- `rooms` - Rooms within homes
- `devices` - Smart devices
- `device_logs` - Device activity logs

See the database diagram for detailed schema structure.

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Supabase** - Backend as a Service (Auth, Database, Realtime)
- **Provider** - State management
- **Google Fonts** - Typography
- **Flutter Animate** - Smooth animations

## Screenshots

Coming soon! Run the app to see the beautiful UI in action.

## License

MIT License - feel free to use this project as you wish.
