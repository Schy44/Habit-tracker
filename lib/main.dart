import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mytracker/providers/quote_provider.dart';
import 'package:mytracker/screens/favorites_screen.dart';
import 'package:mytracker/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:mytracker/providers/auth_provider.dart' as auth_provider; // Alias my AuthProvider
import 'package:mytracker/providers/theme_notifier.dart';
import 'package:mytracker/providers/habit_provider.dart';
import 'package:mytracker/screens/login_screen.dart';
import 'package:mytracker/screens/signup_screen.dart';
import 'package:mytracker/screens/settings_screen.dart'; // Import SettingsScreen
import 'package:mytracker/screens/profile_screen.dart'; // Import ProfileScreen
import 'package:mytracker/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => auth_provider.AuthProvider()), // Use aliased AuthProvider
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => HabitProvider()),
        ChangeNotifierProvider(create: (context) => QuoteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _SlideRightTransitionBuilder(),
        TargetPlatform.iOS: _SlideRightTransitionBuilder(),
        TargetPlatform.windows: _SlideRightTransitionBuilder(),
      },
    );

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'MyTracker',
          theme: AppTheme.lightTheme.copyWith(pageTransitionsTheme: pageTransitionsTheme),
          darkTheme: AppTheme.darkTheme.copyWith(pageTransitionsTheme: pageTransitionsTheme),
          themeMode: themeNotifier.themeMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => const HomeScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/profile': (context) => const ProfileScreen(), // Add ProfileScreen route
            '/favorites': (context) => const FavoritesScreen(),
          },
        );
      },
    );
  }
}

class _SlideRightTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: child,
    );
  }
}
