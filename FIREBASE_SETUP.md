# 🔐 SECURITY NOTICE

**This repository does NOT contain Firebase API keys or sensitive configuration.**

## ⚠️ Required Setup Before Running

You need to obtain these files from your Firebase console and place them in the correct locations:
- `lib/firebase_options.dart` - Generate using `flutterfire configure`
- `android/app/google-services.json` - Download from Firebase console  
- `ios/Runner/GoogleService-Info.plist` - Download from Firebase console

**Template files are provided with placeholder values. Never commit real config files.**

---

# Firebase Setup Instructions

This document provides step-by-step instructions for setting up Firebase for the Daily Devotional App.

## Prerequisites

- A Google account
- Flutter SDK installed
- Project cloned and dependencies installed

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `daily-devotional-app`
4. Enable Google Analytics (optional)
5. Click "Create project"

## 2. Configure Android App

1. In Firebase Console, click "Add app" and select Android
2. Enter package name: `com.devotional.daily_devotional_app`
3. Enter app nickname: `Daily Devotional App`
4. Enter SHA-1 certificate fingerprint (optional for development)
5. Click "Register app"

## 3. Download Configuration Files

1. Download `google-services.json` file
2. Place it in `android/app/` directory
3. The file should replace the template file `android/app/google-services.json.template`

## 4. Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable the following providers:
   - **Email/Password**: Enable this provider
   - **Google**: Enable and configure OAuth 2.0 settings

### Google Sign-In Configuration

1. Enable Google provider
2. Enter project support email
3. Download the updated `google-services.json` file
4. Replace the existing file in `android/app/`

## 5. Configure Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location (preferably close to your users)

### Firestore Security Rules

Replace the default rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public read access to devotionals (if you plan to store them in Firestore)
    match /devotionals/{devotionalId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Default deny all other documents
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## 6. Configure Firebase Cloud Messaging (FCM)

1. In Firebase Console, go to "Cloud Messaging"
2. The setup is already configured in the app code
3. Server key will be needed for sending notifications (optional)

## 7. Configure iOS App (Optional)

1. In Firebase Console, click "Add app" and select iOS
2. Enter bundle ID: `com.devotional.dailyDevotionalApp`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory
5. Add it to the iOS project in Xcode

## 8. Update Build Configuration

### Android Build Configuration

The `android/app/build.gradle.kts` file should already include:

```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // This line
}
```

### Android Permissions

The `android/app/src/main/AndroidManifest.xml` should include:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

## 9. Test Firebase Connection

1. Run the app: `flutter run`
2. Try to register a new account
3. Check Firebase Console > Authentication to see if users are created
4. Check Firestore to see if user documents are created

## 10. Production Configuration

### Security Rules for Production

Update Firestore security rules for production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Validate user data structure
      allow write: if request.auth != null && 
                   request.auth.uid == userId &&
                   validateUserData(request.resource.data);
    }
    
    // Read-only access to devotionals
    match /devotionals/{devotionalId} {
      allow read: if request.auth != null;
    }
    
    // Admin-only access to create/update devotionals
    match /devotionals/{devotionalId} {
      allow write: if request.auth != null && 
                   request.auth.token.admin == true;
    }
    
    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}

function validateUserData(data) {
  return data.keys().hasAll(['email', 'name', 'isPremium', 'notificationSettings', 'createdAt']) &&
         data.email is string &&
         data.name is string &&
         data.isPremium is bool &&
         data.notificationSettings is map &&
         data.createdAt is timestamp;
}
```

### Authentication Configuration

1. Configure OAuth 2.0 settings for production
2. Add production domains to authorized domains
3. Set up proper SHA-1 fingerprints for production builds

## 11. Environment Variables

Create a `.env` file in the project root (not committed to git):

```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
GOOGLE_SIGN_IN_CLIENT_ID=your-client-id
```

## Troubleshooting

### Common Issues

1. **Google Services Plugin Error**: Ensure `google-services.json` is in the correct location
2. **Authentication Errors**: Check that providers are enabled in Firebase Console
3. **Firestore Permission Errors**: Verify security rules are correctly configured
4. **Build Errors**: Ensure all Firebase dependencies are properly configured

### Debug Mode

For development, you can enable Firebase debug mode:

```bash
# Android
adb shell setprop debug.firebase.analytics.app com.devotional.daily_devotional_app

# iOS
-FIRDebugEnabled
```

## Support

If you encounter issues:
1. Check the [Firebase Documentation](https://firebase.google.com/docs)
2. Review the [FlutterFire Documentation](https://firebase.flutter.dev/)
3. Check the project's GitHub issues 