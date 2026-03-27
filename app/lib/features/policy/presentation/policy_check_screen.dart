import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PolicyCheckScreen extends StatefulWidget {
  const PolicyCheckScreen({super.key});

  @override
  State<PolicyCheckScreen> createState() => _PolicyCheckScreenState();
}

class _PolicyCheckScreenState extends State<PolicyCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkPolicyStatus();
  }

  Future<void> _checkPolicyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final policyAccepted = prefs.getBool('policy_accepted') ?? false;

    if (mounted) {
      if (policyAccepted) {
        context.go('/home');
      } else {
        // Use the new go_router route
        context.go('/initial-policy');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
