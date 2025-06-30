# Mood Tracker App

A Flutter application that helps users track their daily moods and provides insights into their emotional patterns using Firebase for authentication and data storage.

## Features

### 🔐 Authentication
- Email/password signup and login using Firebase Auth
- Secure user data isolation (each user's data is stored under their UID)
- Automatic session management

### 📝 Daily Mood Logging
- Select from 4 mood types: Happy 😊, Sad 😢, Angry 😠, Neutral 😐
- Add optional notes to describe your day
- One entry per day validation (prevents duplicate entries)
- Color-coded mood selection interface

### 📊 Mood History
- View mood entries from the past 7 days
- Color-coded mood display with emojis
- Edit notes for any day (mood cannot be changed once logged)
- Pull-to-refresh functionality

### 📈 Mood Insights
- **Most Frequent Mood**: Shows your most common mood with visual indicators
- **Happy Days Percentage**: Calculates the percentage of days marked as happy
- **Longest Streak**: Tracks consecutive days with the same mood
- **Mood Distribution**: Visual breakdown of all mood types with percentages

## Firebase Structure

```
users (collection)
├── {UID} (document)
    └── moods (subcollection)
        ├── 2024-01-15 (document)
        │   ├── mood: "happy"
        │   ├── note: "Had a great day"
        │   ├── timestamp: ...
        │   └── userId: "user_uid"
        ├── 2024-01-16 (document)
        └── ...
```

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase project
- Android Studio / VS Code

### 1. Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication with Email/Password provider
   - Create a Firestore database in test mode

2. **Add Android App**
   - In Firebase console, add Android app
   - Use package name: `com.example.moodtracker`
   - Download `google-services.json` and place it in `android/app/`

3. **Add iOS App** (if developing for iOS)
   - In Firebase console, add iOS app
   - Use bundle ID: `com.example.moodtracker`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

### 2. Flutter Setup

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

### 3. Firebase Security Rules

Add these Firestore security rules:

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

## Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── models/
│   └── mood_entry.dart       # Mood data model and utilities
├── services/
│   ├── auth_service.dart     # Firebase Auth operations
│   └── firestore_service.dart # Firestore data operations
└── screens/
    ├── auth_screen.dart      # Login/Signup screen
    ├── home_screen.dart      # Main navigation screen
    ├── mood_log_screen.dart  # Daily mood logging
    ├── mood_history_screen.dart # 7-day mood history
    └── mood_insights_screen.dart # Analytics and insights
```

## Logic Implementation

### Duplicate Entry Prevention
- Checks if mood entry exists for current date before allowing new entry
- Uses date-based document IDs in Firestore for efficient queries

### Streak Calculation
- Sorts mood entries chronologically
- Tracks consecutive days with the same mood type
- Returns the longest streak found

### Analytics Logic
- **Most Frequent Mood**: Counts occurrences of each mood type
- **Happy Percentage**: Calculates ratio of happy days to total days
- **Mood Distribution**: Shows percentage breakdown of all mood types

## Trade-offs and Design Decisions

### Pros
- **Simple and Intuitive**: Clean UI with emoji-based mood selection
- **Secure**: User-level data isolation with Firebase security rules
- **Offline Capable**: Firebase handles offline data synchronization
- **Scalable**: Firestore structure supports future feature additions

### Cons
- **Internet Required**: Firebase dependency means app needs internet connection
- **Limited Analytics**: Basic insights compared to advanced analytics tools
- **No Data Export**: Users cannot export their mood data
- **Fixed Time Range**: History limited to 7 days (could be configurable)

## Future Enhancements

- [ ] Data export functionality
- [ ] Customizable time ranges for history
- [ ] Mood trends and patterns over time
- [ ] Push notifications for daily mood logging
- [ ] Social features (mood sharing with friends)
- [ ] Advanced analytics and charts
- [ ] Offline-first architecture with local storage

## Screenshots

*Add screenshots or screen recordings here showing:*
- Authentication screen
- Mood logging interface
- History view with color-coded moods
- Insights dashboard with analytics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
