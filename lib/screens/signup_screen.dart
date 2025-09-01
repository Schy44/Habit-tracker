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

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _heightController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _passwordMeetsRequirements = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Password requirements tracking
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumbers = false;
  bool _hasMinLength = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();

    // Add password validation listener
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasMinLength = password.length >= 8;
      _passwordMeetsRequirements = _hasUpperCase && _hasLowerCase && _hasNumbers && _hasMinLength;
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateOfBirthController.dispose();
    _heightController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            border: Border.all(
              color: isMet ? Colors.green : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isMet
                  ? const Icon(Icons.check, size: 12, color: Colors.green)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet
                ? Colors.green
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
              const Color(0xFF1a1a2e),
              const Color(0xFF0f0f1e),
            ]
                : [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                top: -80,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header Section
                                  Hero(
                                    tag: 'app_logo',
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      margin: const EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).colorScheme.primary,
                                            Theme.of(context).colorScheme.secondary,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.track_changes,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    'Start Your Journey',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Build better habits, one day at a time',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),

                                  // Display Name Field (REQUIRED)
                                  _buildInputField(
                                    controller: _displayNameController,
                                    label: 'Display Name *',
                                    hint: 'How should we call you?',
                                    icon: Icons.person_outline,
                                    onChanged: authProvider.setSignUpDisplayName,
                                    errorText: authProvider.validationErrors['displayName'],
                                    required: true,
                                  ),
                                  const SizedBox(height: 20),

                                  // Email Field (REQUIRED)
                                  _buildInputField(
                                    controller: _emailController,
                                    label: 'Email Address *',
                                    hint: 'your.email@example.com',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: authProvider.setSignUpEmail,
                                    errorText: authProvider.validationErrors['email'],
                                    required: true,
                                  ),
                                  const SizedBox(height: 20),

                                  // Password Field (REQUIRED)
                                  _buildInputField(
                                    controller: _passwordController,
                                    label: 'Password *',
                                    hint: 'Min. 8 characters',
                                    icon: Icons.lock_outline,
                                    obscureText: !_showPassword,
                                    onChanged: authProvider.setSignUpPassword,
                                    errorText: authProvider.validationErrors['password'],
                                    required: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                    ),
                                  ),

                                  // Password Requirements
                                  if (_passwordController.text.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildPasswordRequirement('At least 8 characters', _hasMinLength),
                                          const SizedBox(height: 8),
                                          _buildPasswordRequirement('One uppercase letter', _hasUpperCase),
                                          const SizedBox(height: 8),
                                          _buildPasswordRequirement('One lowercase letter', _hasLowerCase),
                                          const SizedBox(height: 8),
                                          _buildPasswordRequirement('One number', _hasNumbers),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 20),

                                  // Confirm Password Field (REQUIRED)
                                  _buildInputField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirm Password *',
                                    hint: 'Re-enter your password',
                                    icon: Icons.lock_outline,
                                    obscureText: !_showConfirmPassword,
                                    onChanged: authProvider.setSignUpConfirmPassword,
                                    errorText: authProvider.validationErrors['confirmPassword'],
                                    required: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showConfirmPassword = !_showConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Optional Information Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 20,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Optional Information',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Help us personalize your experience',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Gender Dropdown (OPTIONAL)
                                        _buildDropdownField(
                                          label: 'Gender',
                                          value: authProvider.signUpGender,
                                          items: ['Male', 'Female', 'Other', 'Prefer not to say'],
                                          onChanged: (value) => authProvider.setSignUpGender(value),
                                          icon: Icons.wc,
                                        ),
                                        const SizedBox(height: 16),

                                        // Date of Birth (OPTIONAL)
                                        _buildDateField(
                                          controller: _dateOfBirthController,
                                          label: 'Date of Birth',
                                          hint: 'DD/MM/YYYY',
                                          icon: Icons.cake_outlined,
                                          onTap: () async {
                                            DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime.now(),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme: ColorScheme.light(
                                                      primary: Theme.of(context).colorScheme.primary,
                                                      onPrimary: Colors.white,
                                                      surface: Theme.of(context).colorScheme.surface,
                                                      onSurface: Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (pickedDate != null) {
                                              authProvider.setSignUpDateOfBirth(pickedDate);
                                              _dateOfBirthController.text =
                                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        // Height Field (OPTIONAL)
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: _buildInputField(
                                                controller: _heightController,
                                                label: 'Height',
                                                hint: 'Your height',
                                                icon: Icons.height,
                                                keyboardType: TextInputType.number,
                                                onChanged: (value) {
                                                  authProvider.setSignUpHeight(double.tryParse(value));
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildDropdownField(
                                                label: 'Unit',
                                                value: authProvider.signUpHeightUnit,
                                                items: ['cm', 'ft'],
                                                onChanged: (value) => authProvider.setSignUpHeightUnit(value),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Goal Preferences Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                          Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.flag_outlined,
                                              size: 20,
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'What are your goals?',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: ['Fitness', 'Productivity', 'Learning', 'Wellness']
                                              .map((goal) => _buildGoalChip(
                                            goal,
                                            authProvider.signUpGoalPreferences.contains(goal),
                                                (isSelected) {
                                              authProvider.setSignUpGoalPreference(goal, isSelected);
                                            },
                                          ))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Terms & Conditions (REQUIRED)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: authProvider.termsAccepted
                                          ? Colors.green.withOpacity(0.1)
                                          : Theme.of(context).colorScheme.error.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: authProvider.termsAccepted
                                            ? Colors.green.withOpacity(0.3)
                                            : authProvider.validationErrors['terms'] != null
                                            ? Theme.of(context).colorScheme.error
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.2,
                                          child: Checkbox(
                                            value: authProvider.termsAccepted,
                                            onChanged: (value) {
                                              authProvider.setTermsAccepted(value ?? false);
                                            },
                                            activeColor: Theme.of(context).colorScheme.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'I agree to the ',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurface,
                                                fontSize: 14,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Terms & Conditions',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      // TODO: Navigate to Terms & Conditions
                                                    },
                                                ),
                                                const TextSpan(text: ' *'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (authProvider.validationErrors['terms'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, left: 16),
                                      child: Text(
                                        authProvider.validationErrors['terms']!,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 32),

                                  // Sign Up Button
                                  Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context).colorScheme.secondary,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: authProvider.isLoading
                                          ? null
                                          : () async {
                                        if (authProvider.validateSignUpForm()) {
                                          await authProvider.signUp();
                                          if (authProvider.currentUser != null) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Account created successfully!'),
                                                  backgroundColor: Colors.green,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              );
                                              Navigator.pushReplacementNamed(context, '/home');
                                            }
                                          } else if (authProvider.errorMessage != null) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(authProvider.errorMessage!),
                                                backgroundColor: Theme.of(context).colorScheme.error,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Already have account
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Already have an account? ',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Login',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? errorText,
    bool obscureText = false,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: suffixIcon,
          errorText: errorText,
          filled: true,
          fillColor: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
          ),
          filled: true,
          fillColor: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null
              ? Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          )
              : null,
          filled: true,
          fillColor: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
      ),
    );
  }

  Widget _buildGoalChip(String label, bool isSelected, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      checkmarkColor: Theme.of(context).colorScheme.secondary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}