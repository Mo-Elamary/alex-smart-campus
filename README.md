# Alex Smart Campus

A Flutter Android application for Alexandria University students. It combines a persistent class schedule, live campus announcements, a personal profile and current Alexandria weather.

## Features

- Email/password registration, sign-in and sign-out with Firebase Authentication.
- Private Firestore profile with editable name and image URL; initials are shown when an image is unavailable.
- Live announcements from Firebase Realtime Database.
- Add, edit and delete classes offline using Hive. Classes are stored per signed-in account on the device.
- Persistent light/dark preference using SharedPreferences.
- Current Alexandria temperature and wind via Open-Meteo, with loading, failure and retry states.

## Setup

1. Install Flutter and the Android toolchain, and run `flutter doctor`.
2. Create a Firebase project. Register an Android app with package name `edu.alexu.smart_campus`, then place its downloaded `google-services.json` in `android/app/`.
3. Enable Email/Password in Authentication > Sign-in method. Create a Cloud Firestore database and a Realtime Database. Apply `firestore.rules` and `database.rules.json` to their respective Rules tabs. The announcement rules allow signed-in users to read; add announcements through the Firebase console.
4. Run `flutter pub get`, connect an Android device with USB debugging enabled, and run `flutter run`.

## Announcements

In the Realtime Database console, add records under `announcements`, using a unique child key. Each record has `title` and `body` strings, and a `timestamp` number in Unix milliseconds. For example:

```json
{"title":"Welcome to campus","body":"Check the schedule for your classes.","timestamp":1795600000000}
```

## Demonstration checklist

- Register, sign out, sign in and reopen the application.
- Edit the profile and try both a valid and an invalid image URL.
- Add, edit and delete an announcement in the Firebase console while the app is open.
- Add a class while signed in, enable airplane mode, then add, edit and delete classes and restart the app.
- Toggle dark mode, restart and confirm the preference is retained.
- Observe weather loading and retry with internet disabled.

The schedule is local to the device, not synchronized across devices. Signing in for the first time and using Firebase or weather require internet; the offline demonstration assumes a user has signed in previously and has not signed out.

## Team

Mohamed Elamary · Fahd Mohamed · Abdelrahman Hany · Abdallah Sameh · Ezz Eldin · Marawan Samy · Ziad Ahmed

Seven-member team, subject to confirmation of the course exception.

## Project report

[Read the detailed project report](Alex_Smart_Campus_Project_Report.pdf) for the architecture, code locations, screenshots, technology choices, proposed presentation roles, and demonstration steps. Student IDs and the seven-person exception are pending confirmation.

## Project layout

- `lib/main.dart`: application setup, authentication gate and theme persistence.
- `lib/screens/auth_screen.dart`: registration and sign-in.
- `lib/screens/home_screen.dart`: navigation, weather, schedule, announcements and profile.
- `firestore.rules` and `database.rules.json`: access rules for the Firebase services.
- `test/`: model and schedule interaction tests.

## Validation

Run `flutter analyze` and `flutter test`. The Android debug APK was built and schedule/profile editing and the airplane-mode schedule were tested on a phone. Live announcement editing and deletion can be demonstrated using the Firebase console.
