
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          _buildSettingsSection(
            context,
            title: 'Preferences',
            tiles: [
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Appearance'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.go('/settings/appearance');
                },
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            title: 'About',
            tiles: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Kidness'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Show about dialog or page
                },
              ),
              ListTile(
                leading: const Icon(Icons.policy_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.go('/settings/policy');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget to create a section with a title
  Widget _buildSettingsSection(BuildContext context, {required String title, required List<Widget> tiles}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...tiles,
      ],
    );
  }
}
