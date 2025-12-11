
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum ThemeModeOption { light, dark, system }

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  ThemeModeOption _selectedTheme = ThemeModeOption.system;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
          RadioListTile<ThemeModeOption>(
            title: const Text('Light'),
            value: ThemeModeOption.light,
            groupValue: _selectedTheme,
            onChanged: (ThemeModeOption? value) {
              setState(() {
                _selectedTheme = value!;
                // TODO: Add logic to change theme
              });
            },
          ),
          RadioListTile<ThemeModeOption>(
            title: const Text('Dark'),
            value: ThemeModeOption.dark,
            groupValue: _selectedTheme,
            onChanged: (ThemeModeOption? value) {
              setState(() {
                _selectedTheme = value!;
                // TODO: Add logic to change theme
              });
            },
          ),
          RadioListTile<ThemeModeOption>(
            title: const Text('System Default'),
            value: ThemeModeOption.system,
            groupValue: _selectedTheme,
            onChanged: (ThemeModeOption? value) {
              setState(() {
                _selectedTheme = value!;
                // TODO: Add logic to change theme
              });
            },
          ),
        ],
      ),
    );
  }
}
