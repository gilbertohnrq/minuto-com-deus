# Daily Devotional App 📱

A Flutter-based daily devotional mobile application that provides users with spiritual content, authentication, and notification features.

## Features ✨

- **Daily Devotionals**: Access to daily spiritual content with biblical verses and reflections
- **User Authentication**: Email/password and Google Sign-In integration
- **Push Notifications**: Daily notification reminders for devotional content
- **Offline Support**: Local storage of devotional content for offline access
- **Freemium Model**: Basic features free with premium upgrade options
- **Modern UI**: Clean, responsive design following Material Design guidelines

## Architecture 🏗️

The app follows Clean Architecture principles with:

- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Models, data sources, and repository implementations
- **Presentation Layer**: UI components, providers, and screens
- **Core Layer**: Utilities, constants, and error handling

### State Management

- **Riverpod**: For state management and dependency injection
- **Riverpod Annotations**: For code generation and type safety

### Backend Services

- **Firebase Auth**: User authentication and management
- **Cloud Firestore**: User data storage and synchronization
- **Firebase Messaging**: Push notifications
- **Google Mobile Ads**: Advertisement integration

## Getting Started 🚀

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/daily_devotional_app.git
   cd daily_devotional_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation:**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Set up Firebase:**
   - Follow the detailed instructions in [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md)
   - Replace `android/app/google-services.json.template` with your actual `google-services.json`

5. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── app/                    # App-level configuration
├── core/                   # Core utilities and constants
│   ├── constants/         # App constants
│   ├── errors/           # Custom exceptions
│   └── utils/            # Utility functions
├── data/                  # Data layer
│   ├── datasources/      # Data sources (local/remote)
│   ├── models/           # Data models
│   └── repositories/     # Repository implementations
├── domain/               # Domain layer
│   ├── entities/         # Domain entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Use cases (business logic)
├── presentation/         # Presentation layer
│   ├── providers/        # Riverpod providers
│   ├── screens/          # UI screens
│   └── widgets/          # Reusable UI components
├── services/             # External services
└── main.dart            # App entry point
```

## Building for Production 🔧

### Release Build

Use the provided build script:

```bash
./scripts/build_release.sh
```

Or manually:

```bash
flutter build apk --release
```

### Testing

Run all tests:

```bash
flutter test
```

Run specific test suites:

```bash
flutter test test/unit/
flutter test test/widget/
```

## Configuration ⚙️

### Environment Variables

Create a `.env` file in the project root:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
GOOGLE_SIGN_IN_CLIENT_ID=your-client-id
```

### Firebase Setup

1. Create a Firebase project
2. Enable Authentication (Email/Password and Google)
3. Set up Cloud Firestore
4. Configure push notifications
5. Download `google-services.json` and place in `android/app/`

Detailed instructions: [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md)

## Contributing 🤝

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style

- Follow [Flutter style guide](https://docs.flutter.dev/development/tools/formatting)
- Use `flutter analyze` to check code quality
- Run `flutter format .` to format code

## Testing 🧪

The app includes comprehensive testing:

- **Unit Tests**: Business logic and utilities
- **Widget Tests**: UI components and screens
- **Integration Tests**: End-to-end user flows

Run tests with coverage:

```bash
flutter test --coverage
```

## Deployment 🚀

### Android

1. Configure app signing in `android/app/build.gradle`
2. Build release APK: `flutter build apk --release`
3. Upload to Google Play Store

### iOS

1. Configure signing in Xcode
2. Build release IPA: `flutter build ipa --release`
3. Upload to App Store Connect

## Troubleshooting 🔧

### Common Issues

1. **Build Errors**: Run `flutter clean && flutter pub get`
2. **Firebase Issues**: Check `google-services.json` placement
3. **Dependencies**: Update Flutter and dependencies
4. **Code Generation**: Run `flutter packages pub run build_runner build --delete-conflicting-outputs`

### Debug Mode

Enable debug logging in `main.dart`:

```dart
void main() {
  if (kDebugMode) {
    Logger.root.level = Level.ALL;
  }
  runApp(MyApp());
}
```

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 💬

If you encounter any issues or have questions:

1. Check the [FAQ](FAQ.md)
2. Search existing [issues](https://github.com/your-username/daily_devotional_app/issues)
3. Create a new issue with detailed information
4. Join our [Discord community](https://discord.gg/your-invite)

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Firebase team for backend services
- Open source contributors and community
- Beta testers and early adopters

---

Built with ❤️ using Flutter
