# 📌 MyTracker

![Green Gradient Application Showcase Presentation](https://github.com/user-attachments/assets/2af70e46-a536-4dc0-95e0-096d2a946b80)
![Green Gradient Application Showcase Presentation (1)](https://github.com/user-attachments/assets/5b12ac86-b97f-47b3-b10f-cc06fb707d1d)

MyTracker is a **cross-platform habit tracking app** (mobile + web) built with **Flutter**.
It helps users build positive habits, stay motivated, and gain actionable insights into their daily routines.  
here's the video link - https://drive.google.com/file/d/1I76WotgHRkXLGC8wr_z0jiobRY48fKcU/view?usp=drivesdk 
Project detailed documantation and ui designs are provided here - https://volcano-zephyr-6db.notion.site/MyTracker-Comprehensive-Project-Documentation-131edb06f3c980eca8d9dce47501d85a
## 🚀 Features

- **User Authentication & Profiles**
  - Secure email/password login with Firebase Authentication
  - User profiles with personal details and preferences

- **Comprehensive Habit Tracking**
  - Create, edit, and delete habits with categories, goals, and reminders
  - Track daily/weekly progress with streaks & completion history
  - Swipe actions for quick complete/delete

- **Advanced Statistics & Insights**
  - Interactive charts & dashboards (using **fl_chart**)
  - Weekly/monthly performance breakdown
  - GitHub-style **consistency heatmap**
  - Smart motivational insights & achievement badges

- **Inspirational Quotes**
  - Integrated **DummyJSON Quotes API**
  - Random motivational quotes on the home screen
  - Save and manage favorite quotes in Firestore
  - Copy/share quotes easily

- **Modern UI/UX**
  - Consistent theme with animations & haptic feedback
  - Light/Dark mode support with **google_fonts**
  - Clean, minimal, and user-friendly design

---

## 🛠️ Tech Stack

### Frontend
- **Flutter (Dart)** – UI development (cross-platform)
- **Provider** – State management
- **fl_chart** – Interactive charts
- **carousel_slider** – Quotes carousel
- **flutter_heatmap_calendar** – Consistency heatmap

### Backend
- **Firebase Authentication** – Secure login & registration
- **Cloud Firestore** – Stores user data, habits, and favorites
- **Firebase Storage** – User avatars (planned feature)
- **Firebase Security Rules** – Secure access control

### External API
- **DummyJSON Quotes API** → [https://dummyjson.com/quotes](https://dummyjson.com/quotes)  
  Provides a diverse set of inspirational quotes.

---

## 📂 Project Structure
lib/
 ├── main.dart              # App entry point, Firebase init, routes
 ├── models/                # Data models (User, Habit, Quote)
 ├── providers/             # State management (Auth, Habits, Quotes, Theme)
 ├── screens/               # UI Screens (Home, Login, Statistics, Profile)
 ├── services/              # Business logic (AuthService, HabitService, QuoteService)
 ├── theme/                 # Colors, typography, styles
 ├── utils/                 # Helper functions
 └── widgets/               # Reusable components (HabitCard, StatCard, etc.)



---

## ⚙️ Development Setup

### Prerequisites
- [Flutter SDK 3.9.0+](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- Firebase project configured

### Installation
```bash
# Clone the repository
git clone https://github.com/your-username/mytracker.git
cd mytracker

# Install dependencies
flutter pub get

# Configure Firebase
flutterfire configure

# Run the app
flutter run
```
