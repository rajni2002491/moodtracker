# Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: "Mood Tracker"
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In Firebase Console, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Click "Save"

## Step 3: Create Firestore Database

1. In Firebase Console, go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location closest to your users
5. Click "Done"

## Step 4: Add Android App

1. In Firebase Console, click the gear icon next to "Project Overview"
2. Select "Project settings"
3. Scroll down to "Your apps" section
4. Click the Android icon to add Android app
5. Enter package name: `com.example.moodtracker`
6. Enter app nickname: "Mood Tracker"
7. Click "Register app"
8. Download the `google-services.json` file
9. Place the file in `android/app/` directory

## Step 5: Add iOS App (if needed)

1. In the same "Your apps" section, click the iOS icon
2. Enter bundle ID: `com.example.moodtracker`
3. Enter app nickname: "Mood Tracker"
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place the file in `ios/Runner/` directory

## Step 6: Configure Android Build Files

Update `android/app/build.gradle.kts` to include the Google Services plugin:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Add this line
}
```

Update `android/build.gradle.kts` to include the Google Services classpath:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0") // Add this line
    }
}
```

## Step 7: Set Firestore Security Rules

In Firebase Console, go to Firestore Database > Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/moods/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 8: Test the Setup

1. Run `flutter pub get` to ensure all dependencies are installed
2. Run `flutter run` to start the app
3. Try creating an account and logging in
4. Test mood logging functionality

## Troubleshooting

### Common Issues:

1. **"No Firebase App '[DEFAULT]' has been created"**
   - Ensure `google-services.json` is in the correct location
   - Check that Firebase is properly initialized in `main.dart`

2. **Authentication errors**
   - Verify Email/Password provider is enabled in Firebase Console
   - Check that the package name matches exactly

3. **Firestore permission errors**
   - Ensure security rules are properly set
   - Check that the user is authenticated before accessing data

4. **Build errors**
   - Make sure Google Services plugin is added to build.gradle files
   - Clean and rebuild: `flutter clean && flutter pub get`

## Next Steps

After Firebase is configured:

1. Test all authentication flows (signup, login, logout)
2. Test mood logging and validation
3. Test history and insights features
4. Consider setting up proper security rules for production
5. Add error handling and user feedback 