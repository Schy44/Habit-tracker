# MyTracker: Your Personal Habit Tracker

![App Screenshot Placeholder](https://via.placeholder.com/800x400?text=MyTracker+App+Screenshots)

MyTracker is a modern, intuitive, and feature-rich habit tracking application designed to help you build and maintain positive habits, track your progress, and achieve your personal goals. With engaging gamification elements, insightful analytics, and a clean user interface, MyTracker makes habit formation an enjoyable and rewarding journey.

## ✨ Features

*   **Comprehensive Habit Management:** Create, edit, and track daily, weekly, or custom habits with ease.
*   **Advanced Statistics & Analytics:**
    *   **Journey Overview Dashboard:** Get a quick glance at your overall progress, today's completion rate, and active streaks.
    *   **Interactive Performance Charts:** Visualize your consistency and trends over various time ranges (week, month, quarter, year) with smooth line charts.
    *   **Category Performance Breakdown:** See how you're performing across different habit categories with progress bars and color-coded indicators.
    *   **Weekly Consistency Heatmap:** A GitHub-style heatmap to visualize your daily habit completion intensity over four weeks.
*   **Smart Insights System:** Receive AI-like recommendations and personalized suggestions for improvement based on your habit patterns.
*   **Enhanced Achievement System:** Unlock and track your progress towards various achievements with visual indicators and detailed descriptions.
*   **Engaging Gamification:** Motivate yourself with streaks, achievements, and a streak leaderboard.
*   **Inspirational Quotes:** Stay inspired with a carousel of motivational quotes, featuring copy and favorite functionalities.
*   **User Profile Management:** Customize your profile, including personal details and an avatar.
*   **Intuitive UI/UX:** Enjoy a clean, modern design with smooth animations, haptic feedback, and a consistent sage green theme.
*   **Authentication:** Secure user authentication powered by Firebase.

## 🚀 Technologies Used

*   **Flutter:** Frontend framework for building cross-platform mobile and web applications.
*   **Firebase:** Backend services for:
    *   **Firebase Authentication:** User registration and login.
    *   **Cloud Firestore:** NoSQL database for storing user data, habits, and favorite quotes.
    *   **Firebase Storage:** Cloud storage for user avatars.
*   **`fl_chart`:** Powerful Flutter chart library for data visualization.
*   **`carousel_slider`:** Flexible carousel widget for displaying quotes.
*   **`flutter_heatmap_calendar`:** For visualizing weekly consistency.
*   **`image_picker`:** For selecting images from the device gallery.
*   **`http`:** For making API requests to fetch quotes.
*   **`provider`:** State management solution for Flutter.
*   **`intl`:** For internationalization and date formatting.

## ⚙️ Installation

Follow these steps to set up and run MyTracker locally:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/mytracker.git
    cd mytracker
    ```

2.  **Install Flutter dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Project Setup:**
    *   Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
    *   Enable **Authentication** (Email/Password provider).
    *   Enable **Cloud Firestore**.
    *   Enable **Cloud Storage**.
    *   Add a new Web App to your Firebase project and copy its configuration.
    *   Create `lib/firebase_options.dart` using the FlutterFire CLI:
        ```bash
        flutter pub global activate flutterfire_cli
        flutterfire configure
        ```
        Follow the prompts to select your Firebase project and platforms.

4.  **Update Firebase Security Rules:**
    Go to your Firebase Console -> Firestore Database -> Rules tab and replace the existing rules with the following:
    ```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User-specific data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }

    // Public data (if any, e.g., global quotes - not currently implemented as public)
    // match /public_collection/{documentId} {
    //   allow read: if true;
    // }
  }
}
    ```
    Go to your Firebase Console -> Storage -> Rules tab and replace the existing rules with the following:
    ```firestore
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /user_avatars/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
    ```

5.  **Run the application:**
    ```bash
    flutter run
    ```

## 💡 Usage

*   **Sign Up/Login:** Create an account or log in to start tracking your habits.
*   **Create Habits:** Use the intuitive interface to define your habits, set frequencies, and add reminders.
*   **Track Progress:** Mark habits as complete daily and watch your streaks grow.
*   **Explore Statistics:** Visit the statistics screen to view detailed charts, insights, and achievements.
*   **Manage Profile:** Update your display name, personal details, and avatar in the profile section.

## 🤝 Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. (Note: You might need to create a LICENSE file in your project root if it doesn't exist).

## ✉️ Contact

For any questions or feedback, please contact [Your Name/Email/GitHub Profile].

---

**Note:** This README is a template. Remember to replace placeholder text like `https://github.com/your-username/mytracker.git` and `[Your Name/Email/GitHub Profile]` with your actual project details. You might also want to add actual app screenshots to the placeholder at the top.