import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mytracker/providers/auth_provider.dart';
import 'package:mytracker/providers/theme_notifier.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/theme/app_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Login',
          style: AppTypography.textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.md),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: AppTypography.textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppStyles.xxl),

                    // Email Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email address',
                        errorText: authProvider.validationErrors['email'],
                      ).applyDefaults(AppStyles.inputDecorationTheme),
                      onChanged: authProvider.setLoginEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Password Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        errorText: authProvider.validationErrors['password'],
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ).applyDefaults(AppStyles.inputDecorationTheme),
                      onChanged: authProvider.setLoginPassword,
                      obscureText: !_showPassword,
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: authProvider.rememberMe,
                              onChanged: (value) {
                                authProvider.setRememberMe(value ?? false);
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                            ),
                            Text(
                              'Remember Me',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement Forgot Password flow
                            // print('Forgot Password');
                          },
                          style: AppStyles.textButtonStyle.copyWith(
                            foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppStyles.lg),

                    // Login Button
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (authProvider.validateLoginForm()) {
                                await authProvider.signIn();
                                if (authProvider.currentUser != null) {
                                  if (mounted) Navigator.pushReplacementNamed(context, '/home');
                                } else if (authProvider.errorMessage != null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(authProvider.errorMessage!),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              }
                            },
                      style: AppStyles.primaryButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                        foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                      ),
                      child: authProvider.isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                            )
                          : Text(
                              'Login',
                              style: AppTypography.textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Error Message Display
                    if (authProvider.errorMessage != null)
                      Text(
                        authProvider.errorMessage!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: AppStyles.md),

                    // Don't have an account? Sign Up
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: AppStyles.textButtonStyle.copyWith(
                        foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
                      ),
                      child: Text(
                        'Don\'t have an account? Sign Up',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}