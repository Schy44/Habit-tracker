import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/providers/auth_provider.dart';
import 'package:mytracker/providers/theme_notifier.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/widgets/habit_card.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Settings state
  bool _dailyRemindersEnabled = true;
  bool _streakAlertsEnabled = true;
  bool _weeklySummaryEnabled = false;
  bool _offlineModeEnabled = true;
  bool _autoSyncEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadSettings();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _dailyRemindersEnabled = prefs.getBool('dailyRemindersEnabled') ?? true;
        _streakAlertsEnabled = prefs.getBool('streakAlertsEnabled') ?? true;
        _weeklySummaryEnabled = prefs.getBool('weeklySummaryEnabled') ?? false;
        _offlineModeEnabled = prefs.getBool('offlineModeEnabled') ?? true;
        _autoSyncEnabled = prefs.getBool('autoSyncEnabled') ?? true;

        // Load reminder time
        final hour = prefs.getInt('reminderHour') ?? 9;
        final minute = prefs.getInt('reminderMinute') ?? 0;
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_hasChanges) {
      _showInfoSnackBar('No changes to save');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save all settings to SharedPreferences
      await Future.wait([
        prefs.setBool('dailyRemindersEnabled', _dailyRemindersEnabled),
        prefs.setBool('streakAlertsEnabled', _streakAlertsEnabled),
        prefs.setBool('weeklySummaryEnabled', _weeklySummaryEnabled),
        prefs.setBool('offlineModeEnabled', _offlineModeEnabled),
        prefs.setBool('autoSyncEnabled', _autoSyncEnabled),
        prefs.setInt('reminderHour', _reminderTime.hour),
        prefs.setInt('reminderMinute', _reminderTime.minute),
      ]);

      // TODO: Sync to Firestore when user is authenticated
      await _syncSettingsToFirestore();

      setState(() => _hasChanges = false);
      _showSuccessSnackBar('Settings saved successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to save settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncSettingsToFirestore() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'settings': {
            'dailyRemindersEnabled': _dailyRemindersEnabled,
            'streakAlertsEnabled': _streakAlertsEnabled,
            'weeklySummaryEnabled': _weeklySummaryEnabled,
            'offlineModeEnabled': _offlineModeEnabled,
            'autoSyncEnabled': _autoSyncEnabled,
            'reminderTime': {
              'hour': _reminderTime.hour,
              'minute': _reminderTime.minute,
            },
            'updatedAt': FieldValue.serverTimestamp(),
          }
        });
      }
    } catch (e) {
      print('Failed to sync settings to Firestore: $e');
      // Don't show error to user as this is background sync
    }
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
        _hasChanges = true;
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      // TODO: Implement actual data export
      await Future.delayed(const Duration(seconds: 2)); // Simulate export
      _showSuccessSnackBar('Data exported successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to export data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await _showConfirmationDialog(
      'Clear All Data',
      'This action will permanently delete all your habits, progress, and settings. This cannot be undone.',
      'Clear',
      isDestructive: true,
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);
    HapticFeedback.heavyImpact();

    try {
      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // TODO: Clear Firestore data
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
      }

      _showSuccessSnackBar('All data cleared successfully');

      // Navigate back or restart app
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to clear data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) { // Added url_launcher prefix
        await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication); // Added url_launcher prefix
      } else {
        _showErrorSnackBar('Could not launch $url');
      }
    } catch (e) {
      _showErrorSnackBar('Error launching URL: $e');
    }
  }

  Future<bool> _showConfirmationDialog(
    String title,
    String content,
    String confirmText, {
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Settings'),
        actions: [
          if (_hasChanges)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _isLoading ? null : _saveSettings,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : const Icon(Icons.save_rounded, color: AppColors.primary),
                tooltip: 'Save Changes',
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppearanceSection(themeNotifier),
              const SizedBox(height: 24),
              _buildNotificationsSection(),
              const SizedBox(height: 24),
              _buildDataPrivacySection(),
              const SizedBox(height: 24),
              _buildAboutSection(),
              const SizedBox(height: 32),
              if (_hasChanges) _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(ThemeNotifier themeNotifier) {
    return _buildSection(
      title: 'Appearance',
      icon: Icons.palette_rounded,
      children: [
        _buildThemeSelector(themeNotifier),
        const SizedBox(height: 20),
        _buildThemePreview(themeNotifier),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSection(
      title: 'Notifications',
      icon: Icons.notifications_rounded,
      children: [
        _buildEnhancedToggle(
          'Daily Reminders',
          'Get reminded to complete your habits',
          _dailyRemindersEnabled,
          (value) => setState(() {
            _dailyRemindersEnabled = value;
            _hasChanges = true;
          }),
          Icons.alarm_rounded,
        ),
        if (_dailyRemindersEnabled) ...[
          const SizedBox(height: 12),
          _buildReminderTimeSetting(),
        ],
        const SizedBox(height: 16),
        _buildEnhancedToggle(
          'Streak Alerts',
          'Celebrate your achievement milestones',
          _streakAlertsEnabled,
          (value) => setState(() {
            _streakAlertsEnabled = value;
            _hasChanges = true;
          }),
          Icons.local_fire_department_rounded,
        ),
        const SizedBox(height: 16),
        _buildEnhancedToggle(
          'Weekly Summary',
          'Get your weekly progress report',
          _weeklySummaryEnabled,
          (value) => setState(() {
            _weeklySummaryEnabled = value;
            _hasChanges = true;
          }),
          Icons.analytics_rounded,
        ),
      ],
    );
  }

  Widget _buildDataPrivacySection() {
    return _buildSection(
      title: 'Data & Privacy',
      icon: Icons.security_rounded,
      children: [
        _buildEnhancedToggle(
          'Offline Mode',
          'Save data locally when offline',
          _offlineModeEnabled,
          (value) => setState(() {
            _offlineModeEnabled = value;
            _hasChanges = true;
          }),
          Icons.cloud_off_rounded,
        ),
        const SizedBox(height: 16),
        _buildEnhancedToggle(
          'Auto Sync',
          'Automatically sync data when online',
          _autoSyncEnabled,
          (value) => setState(() {
            _autoSyncEnabled = value;
            _hasChanges = true;
          }),
          Icons.sync_rounded,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Export Data',
                Icons.download_rounded,
                _exportData,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Clear Data',
                Icons.delete_forever_rounded,
                _clearAllData,
                color: AppColors.error,
                isDestructive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      icon: Icons.info_rounded,
      children: [
        _buildInfoTile('App Version', '1.2.0', Icons.phone_android_rounded),
        const SizedBox(height: 12),
        _buildLinkTile(
          'Privacy Policy',
          Icons.privacy_tip_rounded,
          () => _launchUrl('https://example.com/privacy'),
        ),
        const SizedBox(height: 12),
        _buildLinkTile(
          'Terms of Service',
          Icons.description_rounded,
          () => _launchUrl('https://example.com/terms'),
        ),
        const SizedBox(height: 12),
        _buildLinkTile(
          'Contact Support',
          Icons.support_agent_rounded,
          () => _launchUrl('mailto:support@habittracker.com'),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(ThemeNotifier themeNotifier) {
    return Column(
      children: [
        _buildThemeOption(
          'Light Mode',
          Icons.light_mode_rounded,
          ThemeMode.light,
          themeNotifier,
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          'Dark Mode',
          Icons.dark_mode_rounded,
          ThemeMode.dark,
          themeNotifier,
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          'Auto (Follow System)',
          Icons.brightness_auto_rounded,
          ThemeMode.system,
          themeNotifier,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    String title,
    IconData icon,
    ThemeMode mode,
    ThemeNotifier themeNotifier,
  ) {
    final isSelected = themeNotifier.themeMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          themeNotifier.setThemeMode(mode);
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemePreview(ThemeNotifier themeNotifier) {
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme Preview',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          HabitCard(
            habit: sampleHabit,
            isCompleted: true,
            onToggle: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTimeSetting() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primary.withOpacity(0.05),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reminder Time', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Daily at ${_reminderTime.format(context)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _selectReminderTime,
            child: Text('Change', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    required Color color,
    bool isDestructive = false,
  }) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? color.withOpacity(0.1) : color,
        foregroundColor: isDestructive ? color : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: isDestructive ? BorderSide(color: color) : null,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(String title, IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Icon(
                Icons.open_in_new_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
