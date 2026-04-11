# 🏋️ FitNova — Full-Stack Fitness Tracking App

FitNova is a modern fitness tracking mobile application built with **Flutter** (frontend) and **Node.js + Express + MongoDB** (backend).

---

## 🚀 Quick Start

### Step 1: Start the Backend

```bash
cd FitNova/backend
npm install
npm run dev        # Starts on http://localhost:3000
```

Then seed the database (food items + predefined workouts):
```bash
npm run seed
```

### Step 2: Run the Flutter App

```bash
cd FitNova/flutter_app

# First time only — create the Flutter project scaffold
flutter create --project-name fitnova --org com.fitnova --platforms android .

# Then copy all the lib/ files back (they'll be overwritten by flutter create)
# OR use flutter pub get if lib/ files are already in place

flutter pub get
flutter run        # Opens on connected emulator/device
```

### Step 3: Build APK

```bash
cd FitNova/flutter_app
flutter build apk --debug
# APK location: build/app/outputs/flutter-apk/app-debug.apk
```

---

## 📁 Project Structure

```
FitNova/
├── backend/                 ← Node.js + Express + MongoDB
│   ├── server.js
│   ├── .env
│   └── src/
│       ├── config/db.js
│       ├── models/          ← 8 Mongoose schemas
│       ├── controllers/     ← 9 controllers
│       ├── routes/          ← 9 route files
│       ├── middleware/      ← JWT auth, error handler
│       └── utils/
│           └── seedData.js  ← Seed workouts & food
│
└── flutter_app/             ← Flutter (Android)
    └── lib/
        ├── main.dart
        ├── core/            ← Theme, router, constants
        ├── data/
        │   ├── models/      ← Dart data models
        │   ├── services/    ← API service layer
        │   └── providers/   ← Riverpod state
        └── ui/
            ├── screens/     ← 15 screens
            └── main_screen.dart ← Bottom navigation
```

---

## 🌐 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/signup` | Register new user |
| POST | `/api/auth/login` | Login |
| PUT | `/api/auth/profile` | Update profile |
| GET | `/api/dashboard` | Today's summary |
| GET | `/api/workouts` | All workouts |
| POST | `/api/workout-logs` | Log workout session |
| GET | `/api/meals?date=` | Get meals by date |
| POST | `/api/meals` | Add meal |
| GET | `/api/food/search?q=` | Search food items |
| POST | `/api/progress` | Log daily progress |
| GET | `/api/progress/weight` | Weight history chart |
| GET | `/api/goals` | Get user goals |
| POST | `/api/goals` | Create goal |
| GET | `/api/ai/workout-suggestions` | AI workout tips |
| GET | `/api/ai/diet-tips` | AI diet advice |

---

## 📱 Features

- ✅ Email authentication with JWT
- ✅ User profile with age, weight, height, goal
- ✅ Dashboard with steps/calories/water rings
- ✅ 7 predefined workouts (gym + home + outdoor)
- ✅ Custom workout creator
- ✅ Log sets, reps, weight per exercise
- ✅ Meal logging with food search (33 food items)
- ✅ Macro tracking (protein/carbs/fat)
- ✅ Progress charts (fl_chart) - weight trend + steps
- ✅ Goal setting and tracking
- ✅ Rule-based AI suggestions (no API key needed)
- ✅ Dark mode UI with animations
- ✅ Bottom navigation (Home/Workout/Diet/Goals/Profile)

---

## ⚙️ Environment Variables (backend/.env)

```
MONGODB_URI=mongodb://localhost:27017/fitnova
JWT_SECRET=fitnova_super_secret_jwt_key_2024
PORT=3000
```

---

## 📲 APK Testing

For Android Emulator, the backend URL is pre-configured as `10.0.2.2:3000`.
For a real device, change `baseUrl` in `lib/core/constants.dart` to your machine's local IP.

---

## 🔑 Google Sign-In Setup (Optional)

1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app with package name `com.fitnova.fitnova`
3. Download `google-services.json` and replace `flutter_app/android/app/google-services.json`
4. Uncomment the Firebase plugin line in `android/app/build.gradle`
