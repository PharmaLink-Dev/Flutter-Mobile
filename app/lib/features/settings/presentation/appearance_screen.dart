
import 'package:app/features/settings/application/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// We rename the enum in the screen to avoid conflicts if needed elsewhere
enum AppThemeMode { light, dark, system }

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the provider to get and set the theme
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Helper to map app theme enum to Material ThemeMode
    ThemeMode _getThemeMode(AppThemeMode mode) {
      switch (mode) {
        case AppThemeMode.light:
          return ThemeMode.light;
        case AppThemeMode.dark:
          return ThemeMode.dark;
        case AppThemeMode.system:
        default:
          return ThemeMode.system;
      }
    }

    // Helper to map Material ThemeMode back to app theme enum
    AppThemeMode _getAppThemeMode(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return AppThemeMode.light;
        case ThemeMode.dark:
          return AppThemeMode.dark;
        case ThemeMode.system:
        default:
          return AppThemeMode.system;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Explicitly navigate back to the Settings screen.
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: Text(
              'Theme'.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Light'),
            value: AppThemeMode.light,
            groupValue: _getAppThemeMode(themeProvider.themeMode),
            onChanged: (AppThemeMode? value) {
              if (value != null) {
                // Call the provider to update the theme
                themeProvider.setThemeMode(_getThemeMode(value));
              }
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Dark'),
            value: AppThemeMode.dark,
            groupValue: _getAppThemeMode(themeProvider.themeMode),
            onChanged: (AppThemeMode? value) {
              if (value != null) {
                themeProvider.setThemeMode(_getThemeMode(value));
              }
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('System Default'),
            value: AppThemeMode.system,
            groupValue: _getAppThemeMode(themeProvider.themeMode),
            onChanged: (AppThemeMode? value) {
              if (value != null) {
                themeProvider.setThemeMode(_getThemeMode(value));
              }
            },
          ),
        ],
      ),
    );
  }
}
