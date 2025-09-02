# Flutter Task Manager (Firebase)

A beautiful, modern task management app with Firebase Auth, Cloud Firestore CRUD, Push Notifications, and comprehensive user management.

## ✨ Features

- **🔐 Authentication**: Email/password signup and login with profile management
- **📝 Task Management**: Add, edit, toggle, and delete tasks with real-time sync
- **🔍 Task Filtering**: View all, pending, or completed tasks with statistics
- **☁️ Cloud Sync**: Real-time data synchronization with Firestore
- **🔔 Smart Notifications**: 
  - Push notifications (FCM)
  - Task completion celebrations
  - Daily reminders for pending tasks
  - Manual reminder testing
- **⚙️ Settings & Profile**: 
  - Edit display name
  - Change password
  - Notification preferences
  - Account management
- **🎨 Modern UI**: Material 3 design with smooth animations and gradients
- **📱 Cross-Platform**: Android, iOS, and Web support
- **🔄 Real-time Updates**: Live task updates across devices

## 🚀 Setup

1) **Install Flutter SDK** and Android/iOS tooling.

2) **Firebase Project Setup**:
   - Create a project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication → Sign-in method → Email/Password
   - Create Firestore database
   - Add a Flutter app and copy the Firebase config values

3) **Configure Firebase Options**:
   - Open `lib/firebase_options.dart` and fill values, or use `--dart-define`:

```bash
flutter run \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=...
```

4) **Firestore Security Rules**:
```bash
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

5) **Push Notifications Setup**:
   - Firebase Console → Project settings → Cloud Messaging
   - Add Android app with package name: `com.example.flutter_task_manager`
   - Add iOS app with bundle ID: `com.example.flutterTaskManager`
   - Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

## 🏃‍♂️ Run

```bash
flutter pub get
flutter run
```

## 🎯 How to Use

1. **Sign Up/Login**: Create an account with your name, email, and password or sign in with existing credentials
2. **Add Tasks**: Use the input field at the top to add new tasks
3. **Manage Tasks**: 
   - Tap checkbox to mark as complete (triggers celebration notification)
   - Double-tap title to edit
   - Swipe left to delete
4. **Filter Tasks**: Use tabs to view All, Pending, or Completed tasks
5. **View Statistics**: See total, pending, and completed task counts
6. **Settings**: Tap settings icon to manage profile and preferences
7. **Notifications**: 
   - Tap notification icon for FCM token and settings
   - Test pending task reminders
   - Configure notification preferences

## 🔔 Smart Notifications

- **FCM Token**: Displayed in notification settings for testing
- **Task Completion**: Celebration notifications when tasks are marked complete
- **Pending Reminders**: Daily reminders for incomplete tasks
- **Manual Testing**: Test reminder button in notification settings
- **Background**: Notifications work when app is closed
- **Foreground**: Shows local notification when app is open

## ⚙️ Settings & Profile

- **Profile Management**: Edit display name and view account info
- **Security**: Change password with re-authentication
- **Notifications**: Toggle notification types and preferences
- **Account Actions**: Logout and delete account options
- **App Info**: Version and feature information

## 🎨 UI Features

- **Material 3 Design**: Modern, adaptive design system
- **Gradient Backgrounds**: Subtle, elegant gradients throughout
- **Smooth Animations**: Fade-in effects and transitions
- **Task Statistics**: Beautiful cards showing task counts
- **Filter Tabs**: Clean tab interface for task filtering
- **Responsive Layout**: Adapts to different screen sizes
- **Interactive Elements**: Hover effects and visual feedback

## 📱 Platform Support

- **Android**: Full native support with Material Design
- **iOS**: Native iOS look and feel
- **Web**: Responsive web interface
- **Desktop**: Windows, macOS, and Linux support

## 🛠️ Technical Stack

- **Frontend**: Flutter with Material 3
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **State Management**: Flutter built-in state management
- **Real-time**: Firestore streams for live updates
- **Notifications**: Firebase Cloud Messaging + Local Notifications
- **Authentication**: Firebase Auth with email/password

## 📋 Dependencies

- `firebase_core`: Firebase initialization
- `firebase_auth`: User authentication
- `cloud_firestore`: Database operations
- `firebase_messaging`: Push notifications
- `flutter_local_notifications`: Local notification display

## 🚀 Deployment

### Android
- Build APK: `flutter build apk`
- Build App Bundle: `flutter build appbundle`
- Update `applicationId` in `android/app/build.gradle`

### iOS
- Open `ios/Runner.xcworkspace` in Xcode
- Update bundle identifier
- Add `GoogleService-Info.plist`
- Build: `flutter build ios`

### Web
- Build: `flutter build web`
- Deploy to any static hosting service

## 🔧 Troubleshooting

- **Firebase Connection**: Ensure `firebase_options.dart` has correct values
- **Notifications**: Check device permissions and Firebase project setup
- **Build Issues**: Run `flutter clean` and `flutter pub get`
- **Task Filtering**: Ensure Firestore indexes are created for complex queries

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
