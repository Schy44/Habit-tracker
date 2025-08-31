import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mytracker/providers/auth_provider.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:flutter/gestures.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: AppTypography.textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
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
                      'Create your account',
                      style: AppTypography.textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppStyles.xxl),

                    // Display Name Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        hintText: 'Enter your display name',
                        errorText: authProvider.validationErrors['displayName'],
                      ).applyDefaults(AppStyles.inputDecorationTheme),
                      onChanged: authProvider.setSignUpDisplayName,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Email Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email address',
                        errorText: authProvider.validationErrors['email'],
                      ).applyDefaults(AppStyles.inputDecorationTheme),
                      onChanged: authProvider.setSignUpEmail,
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
                      onChanged: authProvider.setSignUpPassword,
                      obscureText: !_showPassword,
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Confirm Password Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        errorText: authProvider.validationErrors['confirmPassword'],
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                        ),
                      ).applyDefaults(AppStyles.inputDecorationTheme),
                      onChanged: authProvider.setSignUpConfirmPassword,
                      obscureText: !_showConfirmPassword,
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        hintText: 'Select your gender',
                      ).applyDefaults(AppStyles.inputDecorationTheme),
                      value: authProvider.signUpGender,
                      onChanged: (String? newValue) {
                        authProvider.setSignUpGender(newValue);
                      },
                      items: <String>['Male', 'Female', 'Other', 'Prefer not to say']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Date of Birth Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'Select your date of birth',
                      ).applyDefaults(AppStyles.inputDecorationTheme),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          authProvider.setSignUpDateOfBirth(pickedDate);
                          // Update the text field with the selected date
                          _dateOfBirthController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                        }
                      },
                      controller: _dateOfBirthController,
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Height Field
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Height',
                              hintText: 'Enter your height',
                            ).applyDefaults(AppStyles.inputDecorationTheme),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              authProvider.setSignUpHeight(double.tryParse(value));
                            },
                            controller: _heightController,
                          ),
                        ),
                        SizedBox(width: AppStyles.md),
                        SizedBox(
                          width: 100,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              hintText: 'Unit',
                            ).applyDefaults(AppStyles.inputDecorationTheme),
                            value: authProvider.signUpHeightUnit,
                            onChanged: (String? newValue) {
                              authProvider.setSignUpHeightUnit(newValue);
                            },
                            items: <String>['cm', 'ft']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Goal Setting Preferences
                    Text(
                      'Goal Setting Preferences',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppStyles.sm),
                    Column(
                      children: [
                        for (var goal in ['Fitness', 'Productivity', 'Learning', 'Wellness'])
                          CheckboxListTile(
                            title: Text(goal),
                            value: authProvider.signUpGoalPreferences.contains(goal),
                            onChanged: (bool? isSelected) {
                              authProvider.setSignUpGoalPreference(goal, isSelected ?? false);
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.md),

                    // Terms & Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: authProvider.termsAccepted,
                          onChanged: (value) {
                            authProvider.setTermsAccepted(value ?? false);
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO: Navigate to Terms & Conditions page
                                      // print('Navigate to T&C');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (authProvider.validationErrors['terms'] != null)
                      Padding(
                        padding: const EdgeInsets.only(left: AppStyles.md),
                        child: Text(
                          authProvider.validationErrors['terms']!,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppStyles.lg),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (authProvider.validateSignUpForm()) {
                                await authProvider.signUp();
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
                              'Sign Up',
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

                    // Already have an account? Login
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: AppStyles.textButtonStyle.copyWith(
                        foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
                      ),
                      child: Text(
                        'Already have an account? Login',
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