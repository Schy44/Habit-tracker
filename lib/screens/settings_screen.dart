import 'package:flutter/material.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/providers/theme_notifier.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/widgets/habit_card.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp
import 'package:mytracker/theme/app_theme.dart'; // Import for AppTheme
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _selectedThemeMode;
  bool _dailyRemindersEnabled = false;
  bool _streakAlertsEnabled = false;
  bool _weeklySummaryEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedThemeMode = Provider.of<ThemeNotifier>(context, listen: false).themeMode;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyRemindersEnabled = prefs.getBool('dailyRemindersEnabled') ?? false;
      _streakAlertsEnabled = prefs.getBool('streakAlertsEnabled') ?? false;
      _weeklySummaryEnabled = prefs.getBool('weeklySummaryEnabled') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyRemindersEnabled', _dailyRemindersEnabled);
    await prefs.setBool('streakAlertsEnabled', _streakAlertsEnabled);
    await prefs.setBool('weeklySummaryEnabled', _weeklySummaryEnabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.save), tooltip: 'Save Changes', onPressed: _saveSettings),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance'),
            _buildCard(
              child: Column(
                children: [
                  _buildThemeModeRadio(context, 'Light Mode', ThemeMode.light),
                  _buildThemeModeRadio(context, 'Dark Mode', ThemeMode.dark),
                  _buildThemeModeRadio(context, 'Auto (Follow System)', ThemeMode.system),
                  const Divider(height: AppStyles.lg),
                  Text('Theme Preview:', style: AppTypography.textTheme.bodyLarge),
                  const SizedBox(height: AppStyles.md),
                  _buildThemePreviewCard(themeNotifier.themeMode),
                ],
              ),
            ),
            _buildSectionHeader('Notifications'),
            _buildCard(
              child: Column(
                children: [
                  _buildToggleSetting('Daily Reminders', _dailyRemindersEnabled, (value) {
                    setState(() => _dailyRemindersEnabled = value);
                  }),
                  _buildEditableSetting('Reminder Time: 9:00 AM', () {}), // Placeholder
                  _buildToggleSetting('Streak Alerts', _streakAlertsEnabled, (value) {
                    setState(() => _streakAlertsEnabled = value);
                  }),
                  _buildToggleSetting('Weekly Summary', _weeklySummaryEnabled, (value) {
                    setState(() => _weeklySummaryEnabled = value);
                  }),
                ],
              ),
            ),
            _buildSectionHeader('Data & Privacy'),
            _buildCard(
              child: Column(
                children: [
                  _buildToggleSetting('Offline Mode', false, (value) {}), // Placeholder
                  _buildToggleSetting('Auto Sync', true, (value) {}), // Placeholder
                  _buildButtonSetting('Export My Data', () {}), // Placeholder
                  _buildButtonSetting('Clear All Data', () {}), // Placeholder
                ],
              ),
            ),
            _buildSectionHeader('About'),
            _buildCard(
              child: Column(
                children: [
                  _buildInfoSetting('App Version: 1.2.0'),
                  _buildLinkSetting('Privacy Policy', () {}), // Placeholder
                  _buildLinkSetting('Terms of Service', () {}), // Placeholder
                  _buildLinkSetting('Contact Support', () {}), // Placeholder
                ],
              ),
            ),
            const SizedBox(height: AppStyles.lg),
            Center(
              child: ElevatedButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: _saveSettings,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.md),
      child: Text(title, style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppStyles.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.md),
        child: child,
      ),
    );
  }

  Widget _buildThemeModeRadio(BuildContext context, String title, ThemeMode mode) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return RadioListTile<ThemeMode>(
      title: Text(title, style: AppTypography.textTheme.bodyLarge),
      value: mode,
      groupValue: _selectedThemeMode,
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedThemeMode = newValue;
          });
          themeNotifier.setThemeMode(newValue);
        }
      },
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildThemePreviewCard(ThemeMode currentThemeMode) {
    // This is a simplified Habit object for preview purposes
    final sampleHabit = Habit(
      id: 'preview',
      userId: 'previewUser',
      title: 'Sample Habit Card',
      category: 'Health',
      frequency: 'Daily',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      completedDates: [],
      currentStreak: 5,
      bestStreak: 10,
      isArchived: false,
    );

    return Theme(
      data: currentThemeMode == ThemeMode.light ? AppTheme.lightTheme : AppTheme.darkTheme,
      child: Builder(
        builder: (innerContext) => HabitCard(
          habit: sampleHabit,
          isCompleted: true,
          onToggle: (value) {},
        ),
      ),
    );
  }

  Widget _buildToggleSetting(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: AppTypography.textTheme.bodyLarge),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildEditableSetting(String title, VoidCallback onPressed) {
    return ListTile(
      title: Text(title, style: AppTypography.textTheme.bodyLarge),
      trailing: TextButton(onPressed: onPressed, child: const Text('Edit')),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildButtonSetting(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.xs),
      child: OutlinedButton(
        style: AppStyles.secondaryButtonStyle,
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }

  Widget _buildInfoSetting(String title) {
    return ListTile(
      title: Text(title, style: AppTypography.textTheme.bodyLarge),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLinkSetting(String title, VoidCallback onPressed) {
    return ListTile(
      title: Text(title, style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.primary)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onPressed,
      contentPadding: EdgeInsets.zero,
    );
  }
}
