import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mytracker/providers/auth_provider.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _heightController;

  String? _selectedGender;
  String? _selectedHeightUnit;
  final List<String> _selectedGoalPreferences = [];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    _displayNameController = TextEditingController(text: user?.displayName ?? '');
    _dateOfBirthController = TextEditingController();
    _heightController = TextEditingController();

    // Load existing user data if available
    if (user != null) {
      // Assuming user data is also stored in AuthProvider or can be fetched
      // For now, using placeholders or directly from AuthProvider's signUp fields
      _selectedGender = authProvider.signUpGender; // This is from signup form, not actual user profile
      _selectedHeightUnit = authProvider.signUpHeightUnit;
      _selectedGoalPreferences.addAll(authProvider.signUpGoalPreferences);

      if (authProvider.signUpDateOfBirth != null) {
        _dateOfBirthController.text = DateFormat('yMMMd').format(authProvider.signUpDateOfBirth!);
      }
      if (authProvider.signUpHeight != null) {
        _heightController.text = authProvider.signUpHeight.toString();
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _dateOfBirthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No user logged in.')),
        );
        return;
      }

      Map<String, dynamic> userData = {
        'displayName': _displayNameController.text,
        'gender': _selectedGender,
        'dateOfBirth': _dateOfBirthController.text.isNotEmpty ? Timestamp.fromDate(DateFormat('yMMMd').parse(_dateOfBirthController.text)) : null,
        'height': double.tryParse(_heightController.text),
        'heightUnit': _selectedHeightUnit,
        'goalPreferences': _selectedGoalPreferences,
        'updatedAt': Timestamp.now(),
      };

      try {
        // This will update the user document in Firestore
        await authProvider.updateUserProfile(user.uid, userData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.save), tooltip: 'Save Profile', onPressed: _saveProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email (Read-only)
              Text('Email:', style: AppTypography.textTheme.bodyLarge),
              Text(user?.email ?? 'N/A', style: AppTypography.textTheme.headlineSmall),
              const SizedBox(height: AppStyles.lg),

              // Display Name
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Display name is required.' : null,
              ),
              const SizedBox(height: AppStyles.md),

              // Gender
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                ),
                value: _selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
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

              // Date of Birth
              TextFormField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dateOfBirthController.text.isNotEmpty ? DateFormat('yMMMd').parse(_dateOfBirthController.text) : DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateOfBirthController.text = DateFormat('yMMMd').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: AppStyles.md),

              // Height
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: 'Height',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value != null && value.isNotEmpty && double.tryParse(value) == null ? 'Invalid height.' : null,
                    ),
                  ),
                  const SizedBox(width: AppStyles.md),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Unit',
                      ),
                      value: _selectedHeightUnit,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedHeightUnit = newValue;
                        });
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

              // Goal Preferences
              Text('Goal Preferences', style: AppTypography.textTheme.titleMedium),
              const SizedBox(height: AppStyles.sm),
              Column(
                children: [
                  for (var goal in ['Fitness', 'Productivity', 'Learning', 'Wellness'])
                    CheckboxListTile(
                      title: Text(goal),
                      value: _selectedGoalPreferences.contains(goal),
                      onChanged: (bool? isSelected) {
                        setState(() {
                          if (isSelected ?? false) {
                            _selectedGoalPreferences.add(goal);
                          } else {
                            _selectedGoalPreferences.remove(goal);
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: AppStyles.lg),

              // Sign Out Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  style: AppStyles.primaryButtonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppColors.error),
                  ),
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
